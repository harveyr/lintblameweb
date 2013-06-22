import logging
from flask import render_template, request, flash, redirect, url_for, session
import webapp

logger = logging.getLogger(__name__)

app = webapp.app

@app.route('/')
def index_route():
    logger.debug('here')
    return render_template('index.html')
