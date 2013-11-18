// Generated by CoffeeScript 1.6.3
(function() {
  var APP_NAME, DIRECTIVE_MODULE, SERVICE_MODULE, app;

  APP_NAME = 'lintblame';

  DIRECTIVE_MODULE = "" + APP_NAME + ".directives";

  SERVICE_MODULE = "" + APP_NAME + ".services";

  angular.module(DIRECTIVE_MODULE, []);

  angular.module(SERVICE_MODULE, []);

  angular.module(DIRECTIVE_MODULE).directive('userFeedback', function() {
    var directive;
    return directive = {
      template: "<div class=\"row-fluid\" ng-show=\"fbModel.html\">\n    <div class=\"span12 alert {{fbModel.alertClass}}\">\n        <span class=\"{{fbModel.iconClass}}\" ng-show=\"fbModel.iconClass\"></span>\n        <span ng-bind-html-unsafe=\"fbModel.html\"></span>\n    </div>\n</div>",
      link: function(scope) {
        var setFeedback;
        scope.fbModel = {};
        setFeedback = function(html, alertClass, iconClass) {
          scope.fbModel.html = html;
          scope.fbModel.alertClass = alertClass;
          return scope.fbModel.iconClass = iconClass;
        };
        scope.$on('feedback', function(html, alertClass, iconClass) {
          return setFeedback(html, alertClass, iconClass);
        });
        scope.$on('successFeedback', function(e, html) {
          return setFeedback(html, 'alert-success', 'icon-thumbs-up');
        });
        scope.$on('errorFeedback', function(e, html) {
          return setFeedback(html, 'alert-error', 'icon-exclamation-sign');
        });
        scope.$on('warnFeedback', function(e, html) {
          return setFeedback(html, '', 'icon-info-sign');
        });
        return scope.$on('clearFeedback', function(e) {
          return setFeedback(null, '', '');
        });
      }
    };
  });

  app = angular.module(APP_NAME, ["" + APP_NAME + ".services", "" + APP_NAME + ".directives"]).run(function($rootScope, Api, Lints) {
    var spinOpts;
    $rootScope.appName = "lintblame";
    $rootScope.lintResults = {};
    spinOpts = {
      lines: 10,
      length: 5,
      width: 2,
      radius: 5,
      corners: 1,
      rotate: 0,
      direction: 1,
      color: '#fff',
      speed: 1,
      trail: 60,
      shadow: false,
      hwaccel: false,
      className: 'spinner',
      zIndex: 2e9,
      top: '5px',
      left: '-20px'
    };
    $rootScope.loadingSpinner = new Spinner(spinOpts);
    $rootScope.isSpinning = false;
    $rootScope.setLoading = function(val) {
      var target;
      if (val) {
        if (!$rootScope.isSpinning) {
          target = document.getElementById('loading');
          return $rootScope.loadingSpinner.spin(target);
        }
      } else {
        return $rootScope.loadingSpinner.stop();
      }
    };
    $rootScope.activePaths = function() {
      if (!$rootScope.lintResults) {
        return [];
      }
      return _.keys($rootScope.lintResults);
    };
    return $rootScope.updateResults = function(pathsAndData) {
      var data, lastRefresh, mins, now, path, paths, secs;
      for (path in pathsAndData) {
        data = pathsAndData[path];
        Lints.issueCount(data);
        $rootScope.lintResults[path] = data;
      }
      paths = _.keys($rootScope.lintResults);
      $rootScope.sortedPaths = paths.sort(function(a, b) {
        return Lints.issueCount($rootScope.lintResults[b]) - Lints.issueCount($rootScope.lintResults[a]);
      });
      now = new Date();
      lastRefresh = now.getHours() + ':';
      mins = now.getMinutes();
      if (mins < 10) {
        lastRefresh += '0';
      }
      lastRefresh += mins + ':';
      secs = now.getSeconds();
      if (secs < 10) {
        lastRefresh += '0';
      }
      lastRefresh += secs;
      return $rootScope.lastRefresh = lastRefresh;
    };
  });

  angular.module(SERVICE_MODULE).service('Api', function($q, $http, $rootScope) {
    var Api;
    Api = (function() {
      function Api() {}

      Api.prototype.lastUpdate = null;

      Api.prototype.scan = function() {
        return 'blah';
      };

      Api.prototype.testPath = function(path, branchMode) {
        var config, deferred, request;
        if (branchMode == null) {
          branchMode = false;
        }
        $rootScope.setLoading(true);
        deferred = $q.defer();
        config = {
          url: "/api/testpath",
          params: {
            path: path
          },
          method: 'get',
          cache: false
        };
        if (branchMode) {
          console.log('branchMode:', branchMode);
          config.params.branch = branchMode;
        }
        request = $http(config);
        request.success(function(response) {
          deferred.resolve(response);
          return $rootScope.setLoading(false);
        });
        return deferred.promise;
      };

      Api.prototype.fullScan = function(paths) {
        var deferred, pathsParam, request;
        $rootScope.setLoading(true);
        this.lastUpdate = Date.now();
        deferred = $q.defer();
        pathsParam = paths.join(',');
        request = $http({
          url: "/api/fullscan",
          params: {
            paths: pathsParam
          },
          method: 'get',
          cache: false
        });
        request.success(function(response) {
          deferred.resolve(response);
          return $rootScope.setLoading(false);
        });
        return deferred.promise;
      };

      Api.prototype.poll = function(paths) {
        var deferred, request,
          _this = this;
        deferred = $q.defer();
        request = $http({
          url: '/api/poll',
          method: 'get',
          params: {
            paths: paths.join(','),
            since: this.lastUpdate
          },
          cache: false
        });
        request.success(function(response) {
          if (!_.isEmpty(response)) {
            _this.lastUpdate = Date.now();
          }
          return deferred.resolve(response);
        });
        return deferred.promise;
      };

      return Api;

    })();
    return new Api();
  });

  angular.module(APP_NAME).controller('MenuCtrl', function($scope, $rootScope, Api) {
    var testPath, _targetPathChange;
    $rootScope.branchMode = false;
    _targetPathChange = function(andAccept) {
      var path;
      path = $scope.targetPathInput;
      if (path) {
        $scope.pathAccepted = false;
        return Api.testPath(path, $rootScope.branchMode).then(function(response) {
          $scope.pathExists = response.exists;
          $rootScope.targets = response.targets;
          if (!_.isUndefined(response.vcs)) {
            $scope.vcs = response.vcs;
            $scope.branch = response.branch;
          }
          if (andAccept) {
            return $scope.acceptPath();
          }
        });
      }
    };
    $scope.targetPathChange = _.throttle(_targetPathChange, 1000);
    $scope.acceptPath = function() {
      if (!$rootScope.targets || $rootScope.targets.length === 0) {
        return;
      }
      $scope.pathAccepted = true;
      return Api.fullScan($rootScope.targets).then(function(response) {
        return $rootScope.updateResults(response);
      });
    };
    $scope.poll = function() {
      return $scope.pollInterval = $interval(function() {
        var paths;
        paths = $rootScope.activePaths();
        if (paths.length > 0) {
          return Api.poll($rootScope.targets).then(function(response) {
            if (!_.isEmpty(response)) {
              return $rootScope.updateResults(response);
            }
          });
        }
      }, 2000);
    };
    $scope.toggleBranchMode = function() {
      $rootScope.branchMode = !$rootScope.branchMode;
      return $scope.targetPathChange(true);
    };
    testPath = '~/dev/ua/airship/airship/apps/messages';
    $scope.targetPathInput = testPath;
    return _targetPathChange(true);
  });

  angular.module(DIRECTIVE_MODULE).directive('lintIssues', function() {
    var directive;
    return directive = {
      replace: true,
      scope: {
        path: '=',
        data: '='
      },
      template: "<div class=\"lint-issues\">\n    <div>\n        <span class=\"label {{countClass}}\">{{totalCount}}</span>\n            &nbsp;\n        <span class=\"dim\">{{pathParts[0]}}/</span><strong>{{pathParts[1]}}</strong>                    \n    </div>\n    <div ng-repeat=\"line in sortedLines\" class=\"line-wrapper\">\n        <code class=\"code\">\n            {{data.lines[line]}}\n        </code>\n        <div ng-repeat=\"issue in issuesByLine[line]\" class=\"issue\">\n            <div class=\"line\">\n                {{issue.line}}<span ng-show=\"issue.column\">:{{issue.column}}</span>\n            </div>\n            <div class=\"reporter\">\n                [{{issue.reporter}}<span ng-show=\"issue.code\"> {{issue.code}}</span>]\n            </div>\n            <div class=\"blame\">\n                [{{blameLine(issue.line)}}]\n            </div>\n            <div class=\"message\">\n                {{issue.message}}\n            </div>\n        </div>\n    </div>\n</div>",
      link: function(scope) {
        scope.update = function() {
          var issue, issuesByLine, line, lineInts, pathParts, totalCount, _i, _len, _ref;
          issuesByLine = {};
          totalCount = 0;
          _ref = scope.data.issues;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            issue = _ref[_i];
            line = issue.line;
            if (!_.has(issuesByLine, line)) {
              issuesByLine[line] = [];
            }
            issuesByLine[line].push(issue);
            totalCount += 1;
          }
          scope.issuesByLine = issuesByLine;
          scope.totalCount = totalCount;
          if (totalCount) {
            scope.countClass = 'label-warning';
          } else {
            scope.countClass = 'label-success';
          }
          lineInts = _.map(issuesByLine, function(issue, line) {
            return parseInt(line, 10);
          });
          scope.sortedLines = lineInts.sort(function(a, b) {
            return a - b;
          });
          pathParts = scope.path.split('/');
          scope.pathParts = [];
          if (pathParts.length > 1) {
            scope.pathParts.push(pathParts.slice(0, pathParts.length - 1).join('/'));
          } else {
            scope.pathParts.push('');
          }
          return scope.pathParts.push(pathParts[pathParts.length - 1]);
        };
        scope.blameLine = function(line) {
          return scope.data.blame[line];
        };
        return scope.$watch('data', function() {
          return scope.update();
        });
      }
    };
  });

  angular.module(APP_NAME).controller('ResultsCtrl', function($scope, $rootScope, $interval, Api) {});

  angular.module(SERVICE_MODULE).service('Lints', function($rootScope) {
    var Lints;
    Lints = (function() {
      function Lints() {}

      Lints.prototype.issueCount = function(lintData) {
        return lintData.issues.length;
      };

      return Lints;

    })();
    return new Lints();
  });

}).call(this);