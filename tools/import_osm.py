"""Prepare um recorte OSM real. Python 3.11, sem dependências externas.

O JSON original comprimido acompanha o derivado para permitir auditoria e redistribuição ODbL.
"""
import argparse
import gzip
import hashlib
import json
import math
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BBOX = (-22.920, -47.078, -22.890, -47.046)
QUERY = f'[out:json][timeout:120];way["highway"]({",".join(map(str, BBOX))})->.roads;(.roads;rel(bw.roads)["type"="restriction"];);out body;>;out skel qt;'
ALLOWED = {'motorway', 'motorway_link', 'trunk', 'trunk_link', 'primary', 'primary_link',
           'secondary', 'secondary_link', 'tertiary', 'tertiary_link', 'residential',
           'unclassified', 'living_street', 'service', 'road'}


def prepare(raw, retrieved):
    source = json.loads(raw)
    elements = source['elements']
    nodes = {n['id']: n for n in elements if n['type'] == 'node'}
    restricted = set()
    for relation in elements:
        if relation['type'] != 'relation':
            continue
        tags = relation.get('tags', {})
        if 'bus' in tags.get('except', '').split(';'):
            continue
        restricted.update(m['ref'] for m in relation.get('members', []) if m['role'] == 'from' and m['type'] == 'way')
    points, edges, roads = {}, [], []
    lon0, lat0 = -47.062, -22.905
    def point(node_id):
        n = nodes[node_id]
        return [round((n['lon'] - lon0) * 111320 * math.cos(math.radians(lat0)), 2),
                round(-(n['lat'] - lat0) * 111320, 2)]
    for way in elements:
        if way['type'] != 'way':
            continue
        tags = way.get('tags', {})
        if tags.get('highway') not in ALLOWED:
            continue
        access = tags.get('bus', tags.get('psv', tags.get('motor_vehicle', tags.get('vehicle', tags.get('access', 'yes')))))
        if access in {'no', 'private', 'destination', 'delivery', 'customers'} or tags.get('area') == 'yes':
            continue
        ids = [i for i in way['nodes'] if i in nodes]
        if len(ids) < 2:
            continue
        for node_id in ids:
            points[str(node_id)] = point(node_id)
        roads.append({'id': way['id'], 'nodes': ids, 'name': tags.get('name', ''), 'kind': tags['highway']})
        if way['id'] in restricted:
            continue
        direction = tags.get('oneway:bus', tags.get('oneway:psv', tags.get('oneway', 'yes' if tags.get('junction') == 'roundabout' or tags['highway'] == 'motorway' else 'no')))
        for a, b in zip(ids, ids[1:]):
            distance = math.dist(points[str(a)], points[str(b)])
            if distance < 0.01:
                continue
            if direction != '-1':
                edges.append([a, b, round(distance, 2)])
            if direction not in {'yes', '1', 'true'}:
                edges.append([b, a, round(distance, 2)])
    # Maior componente fortemente conexo para sugerir pontos com ida e volta válidas.
    adj, rev = {}, {}
    for a, b, _ in edges:
        adj.setdefault(a, []).append(b)
        rev.setdefault(b, []).append(a)
    seen, order = set(), []
    for start in adj:
        if start in seen:
            continue
        stack = [(start, False)]
        while stack:
            n, done = stack.pop()
            if done:
                order.append(n)
            elif n not in seen:
                seen.add(n)
                stack.append((n, True))
                stack.extend((v, False) for v in adj.get(n, []) if v not in seen)
    seen, components = set(), []
    for start in reversed(order):
        if start in seen:
            continue
        component, stack = [], [start]
        seen.add(start)
        while stack:
            n = stack.pop()
            component.append(n)
            for v in rev.get(n, []):
                if v not in seen:
                    seen.add(v)
                    stack.append(v)
        components.append(component)
    core = set(max(components, key=len))
    stops = []
    for road in sorted(roads, key=lambda r: (r['kind'] not in {'primary', 'secondary', 'tertiary'}, r['id'])):
        for node_id in road['nodes']:
            if node_id not in core:
                continue
            p = points[str(node_id)]
            if any(math.dist(p, points[str(s['node'])]) < 380 for s in stops):
                continue
            stops.append({'id': len(stops), 'node': node_id,
                          'name': road['name'] or f'Ponto sugerido {len(stops) + 1}',
                          'estimated': True, 'daily_demand': 300 + len(stops) % 5 * 65})
    assert len(stops) >= 4, 'Recorte insuficiente para o protótipo'
    return {'schema_version': 1, 'city': 'Campinas', 'state': 'SP', 'ibge_code': '3509502',
            'coverage': 'Recorte central; não representa toda Campinas', 'bbox': BBOX,
            'source': 'https://www.openstreetmap.org', 'license': 'ODbL-1.0',
            'attribution': '© OpenStreetMap contributors', 'license_url': 'https://www.openstreetmap.org/copyright',
            'retrieved_at': retrieved, 'osm_timestamp': source.get('osm3s', {}).get('timestamp_osm_base'),
            'raw_sha256': hashlib.sha256(raw).hexdigest(), 'query': QUERY,
            'routing_policy': 'Bus-accessible directed ways; restriction from-ways blocked conservatively; no invented connections.',
            'blocked_restriction_ways': sorted(restricted), 'points': points, 'edges': edges,
            'roads': roads, 'stops': stops}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--download', action='store_true')
    args = parser.parse_args()
    folder = ROOT / 'data/campinas'
    folder.mkdir(parents=True, exist_ok=True)
    raw_path = folder / 'source.osm.json.gz'
    metadata = folder / 'source_metadata.json'
    if args.download:
        request = urllib.request.Request('https://overpass-api.de/api/interpreter',
            data=urllib.parse.urlencode({'data': QUERY}).encode(),
            headers={'User-Agent': 'RotasDoPoderPrototype/0.1 (offline educational game)'})
        with urllib.request.urlopen(request, timeout=180) as response:
            raw = response.read()
        json.loads(raw)
        raw_path.write_bytes(gzip.compress(raw, mtime=0))
        metadata.write_text(json.dumps({'retrieved_at': datetime.now(timezone.utc).isoformat()}, indent=2), encoding='utf-8')
    raw = gzip.decompress(raw_path.read_bytes())
    result = prepare(raw, json.loads(metadata.read_text())['retrieved_at'])
    (folder / 'graph.json').write_text(json.dumps(result, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f"Grafo real: {len(result['points'])} nós, {len(result['edges'])} arestas, {len(result['stops'])} pontos sugeridos")


if __name__ == '__main__':
    main()
