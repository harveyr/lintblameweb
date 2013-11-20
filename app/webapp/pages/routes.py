import logging
from flask import render_template, Blueprint

logger = logging.getLogger(__name__)

blueprint = Blueprint('pages', __name__, template_folder='templates')


@blueprint.route('/')
def index_route():
    return render_template('index.html')
