#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import logging

import webapp
from webapp import routes

app = webapp.app
logger = logging.getLogger('webapp')


def main():
    app.run(port=webapp.PORT, host=webapp.HOST)

if __name__ == "__main__":
    main()
