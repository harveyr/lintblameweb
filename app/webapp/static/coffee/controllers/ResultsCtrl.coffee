angular.module(APP_NAME).controller 'ResultsCtrl', ($scope, $rootScope, $interval, Api) ->
    polling = false

    $scope.pollInterval = $interval ->
        paths = $rootScope.activePaths()
        if paths.length > 0
            Api.poll($rootScope.targets).then (response) ->
                for path, data of response
                    console.log 'path:', path
                    console.log 'data:', data
                    $rootScope.updateResults path, data
    , 2000
