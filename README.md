# fangapp

A web app shell built on a few of my favorite things:

* [Flask](http://flask.pocoo.org/)
* [AngularJs](http://angularjs.org/)
* [CoffeeScript](http://coffeescript.org/)
* [Twitter Bootstrap](http://twitter.github.io/bootstrap/)
* [SASS](http://sass-lang.com/)

**Disclaimer:** This is a quick, simple app to hopefully save me some time in the long run. It's not meant to be a statement of best practices. That said, if you spot any _bad_ practices, please let me know!

## Requirements

(In addition to what's listed above.)

1. Python (2.7 to be safe)
3. [Bower](https://github.com/bower/bower)

## Installation

1. Clone me.
2. Create your virtualenv: `virtualenv path/to/clone`
3. Enter your virtualenv: `cd path/to/clone`, `source bin/activate`
4. Install dependencies: `python buildout.py`
5. Run the app: `python app.py`
6. Point your browser at http://localhost:8123
6. Profiteer!

## Built-in Angular Directives

#### UserFeedback.coffee

This will catch `$scope.$emit` events and populate a little alert div with user feedback.

Examples (in CoffeeScript):

* `$scope.$emit 'successFeedback', 'Nice one!'`
* `$scope.$emit 'errorFeedback', 'Bad one!'`

Or, for control freaks: `$scope.$emit 'feedback', <html>, <alertClass>, <iconClass>`

`alertClass` and `iconClass` refer to CSS classes (for example, Bootstrap's alert and icon classes).

The `<div user-feedback></div>` element in index.html can be moved around, but it should be higher in the scope hierarchy than the controllers that rely on it.

#### TopNavbar.coffee

This creates a vanilla Bootstrap top navbar based on a list of defined nav links in the directive link function. 

Just add your links to that list. The navbar will be populated with them, and the `li.active` class will be added to the DOM automagically.
