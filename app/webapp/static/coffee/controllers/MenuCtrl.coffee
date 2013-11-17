angular.module(APP_NAME).controller 'MenuCtrl', ($scope, $rootScope, Api) ->
    _targetPathChange = (path) ->
        if path
            Api.testPath(path).then (response) ->
                $scope.pathExists = response.exists
                $rootScope.targets = response.targets

                # FOR DEV ONLY
                $scope.acceptPath()

    $scope.targetPathChange = _.throttle(_targetPathChange, 1000)
    
    $scope.acceptPath = ->
        if !$rootScope.targets or $rootScope.targets.length == 0
            return
        Api.fullScan($rootScope.targets).then (response) ->
            $rootScope.lintResults = response
            console.log 'response:', response
            Api.poll($rootScope.targets)


    # testing
    # $scope.targetPathInput = '/Users/harveyrogers/dev/lintblameweb/app/webapp/endpoints/routes.py'
    $scope.targetPathInput = '/Users/harveyrogers/dev/lintblame/lintblame.py'
    _targetPathChange($scope.targetPathInput)
