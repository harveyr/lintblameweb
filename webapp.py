#!/usr/bin/env python
# -*- coding: utf-8 -*-

from app import webapp

app = webapp.app


def main():
    app.run(port=webapp.PORT, host=webapp.HOST)

if __name__ == "__main__":
    main()
