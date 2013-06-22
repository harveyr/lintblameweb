import logging
import sys
import tempfile
# import time

from flask import Flask

HOST = '0.0.0.0'
PORT = 8123
KEY = 'SECRET KEY'

app = Flask('webapp')
app.config.update(DEBUG=True, SECRET_KEY=KEY)

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
LOGHANDLER = logging.StreamHandler()
LOGFORMATTER = logging.Formatter(
    '[%(name)s:%(lineno)d] - %(levelname)s - %(message)s')
LOGHANDLER.setFormatter(LOGFORMATTER)
LOGHANDLER.setLevel(logging.DEBUG)
logger.addHandler(LOGHANDLER)
