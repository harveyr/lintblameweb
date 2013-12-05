angular.module(APP_NAME).controller 'ResultsCtrl', ($scope, $rootScope, $interval, Api) ->
    $scope.demotions = {}

    $scope.$on 'demote', (e, path) ->
        if not _.has $rootScope.lintBundle, 'demotions'
            $rootScope.lintBundle.demotions = {}
        if not _.has $rootScope.lintBundle.demotions, path
            $rootScope.lintBundle.demotions[path] = true
        else
            $rootScope.lintBundle.demotions[path] = !$rootScope.lintBundle.demotions[path]
        $rootScope.saveCurrentBundle()
