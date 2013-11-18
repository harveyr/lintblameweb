import logging
import datetime
import calendar
import json
import os
from werkzeug.contrib.cache import SimpleCache

logger = logging.getLogger(__name__)


def path_dir(path):
    path = path.strip()
    if not os.path.exists(path):
        return None
    if os.path.isfile(path):
        return os.path.split(path)[0]
    return path


def utc_ms(date_obj):
    return (
        calendar.timegm(date_obj.timetuple()) * 1000 +
        date_obj.microsecond / 1000
    )


class LawDiffSerializer(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, datetime.datetime):
            obj_date = calendar.timegm(o.timetuple()) * 1000 + o.microsecond / 1000
            return obj_date


def jsonify(obj):
    return json.dumps(obj, cls=LawDiffSerializer)


cache = SimpleCache()
