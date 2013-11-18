angular.module(APP_NAME).controller 'ResultsCtrl', ($scope, $rootScope, $interval, Api) ->
    $scope.demotions = {}

    $scope.$on 'demote', (e, path) ->
        if not _.has $scope.demotions, path
            $scope.demotions[path] = true
        else
            $scope.demotions[path] = !$scope.demotions[path]
