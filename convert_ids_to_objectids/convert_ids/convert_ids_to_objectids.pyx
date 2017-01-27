import dateutil.parser
from datetime import datetime, date

import simplejson
from bson import DBRef
from bson import ObjectId
from bson.errors import InvalidId

def to_id(id):
    """
    Converts id or string to ObjectId
    """
    if not isinstance(id, basestring):
        return id
    elif len(id) == 24:
        try:
            return ObjectId(id)
        except InvalidId:
            return id
    elif id.isdigit() and len(id) < 15:
        return int(id)
    return id

def recursively_convert_ids(obj):
    if isinstance(obj, list):
        map(lambda item: recursively_convert_ids(item), obj)
    if not isinstance(obj, dict):
        return

    for key, value in obj.iteritems():
        if isinstance(value, list) or isinstance(value, dict):
            recursively_convert_ids(value)
        else:
            convert_ids_in_dict(obj)

def convert_ids_in_dict(obj):
    enc = ComplexTypeEncoder()
    for key in obj:
        if key.endswith('_id') or key == '$id' or key == 'id':
            obj[key] = to_id(obj[key])
        if key.endswith('_ids'):
            obj[key] = map(to_id, obj[key])
        if key.startswith('date_') or key.endswith('_date') or key in ('first_save', 'when', 'utc_start'):
            obj[key] = enc._decode_datetime(obj[key])
    return obj

class ComplexTypeEncoder(simplejson.JSONEncoder):
    """
    Convert datetimes to ISO-8601 strings while encoding a Python structure as JSON
    """
    def _encode_datetime(self, in_datetime):
        """
        Converts a datetime into an ISO 8601 datetime string.
        @param in_datetime:     A datetime
        @return:                The datetime as a string, according to the emerging consensus
                                about datetimes in JSON, something like:
                                1997-07-16T19:20:30.45+01:00
        """
        return in_datetime.replace(microsecond=0).isoformat()


    def _decode_datetime(self, in_string):
        """
        Tries to parse a string as an ISO 8601 datetime. If unsuccessful, returns the original string.
        @param in_string:   A string that may or may not be a datetime, according to the emerging
                            consensus about datetimes in JSON, something like:
                            1997-07-16T19:20:30.45+01:00
        @return:            A datetime if in_string represents a valid datetime, else in_string
        """
        try:
            return dateutil.parser.parse(in_string)
        except:
            try:
                return datetime.strptime(in_string, '%m/%d/%y')
            except:
                return in_string

    # pylint: disable=E0202
    def default(self, obj):
        if isinstance(obj, ObjectId):
            return str(obj)
        if isinstance(obj, datetime):
            return self._encode_datetime(obj)
        if isinstance(obj, date):
            return self._encode_datetime(datetime(obj.year, obj.month, obj.day))
        if isinstance(obj, DBRef):
            return {'$ref': obj.collection, '$id': obj.id}
        return simplejson.JSONEncoder.default(self, obj)
