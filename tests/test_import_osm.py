import gzip
import hashlib
import json
import unittest
from tools.import_osm import ROOT, prepare


class ImportTests(unittest.TestCase):
    def test_real_data_reproducible(self):
        folder = ROOT / 'data/campinas'
        raw = gzip.decompress((folder / 'source.osm.json.gz').read_bytes())
        stored = json.loads((folder / 'graph.json').read_text(encoding='utf-8'))
        self.assertEqual(stored['raw_sha256'], hashlib.sha256(raw).hexdigest())
        rebuilt = prepare(raw, stored['retrieved_at'])
        self.assertEqual(json.loads(json.dumps(rebuilt)), stored)
        self.assertGreater(len(stored['edges']), 1000)
        for stop in stored['stops']:
            self.assertIn(str(stop['node']), stored['points'])
            self.assertTrue(stop['estimated'])

    def test_edges_preserve_osm_direction_and_access(self):
        folder = ROOT / 'data/campinas'
        raw = json.loads(gzip.decompress((folder / 'source.osm.json.gz').read_bytes()))
        stored = json.loads((folder / 'graph.json').read_text(encoding='utf-8'))
        allowed_pairs = set()
        from tools.import_osm import ALLOWED
        for way in raw['elements']:
            if way['type'] != 'way' or way['id'] in stored['blocked_restriction_ways']:
                continue
            tags = way.get('tags', {})
            access = tags.get('bus', tags.get('psv', tags.get('motor_vehicle', tags.get('vehicle', tags.get('access', 'yes')))))
            if tags.get('highway') not in ALLOWED or access in {'no', 'private', 'destination', 'delivery', 'customers'} or tags.get('area') == 'yes':
                continue
            oneway = tags.get('oneway:bus', tags.get('oneway:psv', tags.get('oneway', 'yes' if tags.get('junction') == 'roundabout' or tags['highway'] == 'motorway' else 'no')))
            for a, b in zip(way['nodes'], way['nodes'][1:]):
                if oneway != '-1':
                    allowed_pairs.add((a, b))
                if oneway not in {'yes', '1', 'true'}:
                    allowed_pairs.add((b, a))
        self.assertTrue(all((a, b) in allowed_pairs for a, b, _ in stored['edges']))

    def test_incomplete_source_fails_explicitly(self):
        with self.assertRaises((KeyError, ValueError)):
            prepare(b'{"elements": []}', 'test')


if __name__ == '__main__':
    unittest.main()
