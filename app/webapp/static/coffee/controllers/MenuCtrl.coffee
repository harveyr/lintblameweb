angular.module(APP_NAME).controller 'MenuCtrl', ($scope, $rootScope, Api) ->
    $rootScope.branchMode = false

    _targetPathChange = (andAccept) ->
        path = $scope.targetPathInput
        if path
            $scope.pathAccepted = false
            Api.testPath(path, $rootScope.branchMode).then (response) ->
                $scope.pathExists = response.exists
                $rootScope.targets = response.targets

                if not _.isUndefined response.vcs
                    $scope.vcs = response.vcs
                    $scope.branch = response.branch

                if andAccept
                    $scope.acceptPath()

    $scope.targetPathChange = _.throttle(_targetPathChange, 1000)
    
    $scope.acceptPath = ->
        if !$rootScope.targets or $rootScope.targets.length == 0
            return
        $scope.pathAccepted = true
        Api.fullScan($rootScope.targets).then (response) ->
            $rootScope.updateResults response


    $scope.poll = ->
        $scope.pollInterval = $interval ->
            paths = $rootScope.activePaths()
            if paths.length > 0
                Api.poll($rootScope.targets).then (response) ->
                    if not _.isEmpty response
                        $rootScope.updateResults response
        , 2000

    $scope.toggleBranchMode = ->
        $rootScope.branchMode = !$rootScope.branchMode
        $scope.targetPathChange(true)


    # testing
    # $scope.targetPathInput = '/Users/harveyrogers/dev/lintblameweb/app/webapp/endpoints/routes.py'
    # $scope.targetPathInput = '/Users/harveyrogers/dev/lintblame/lintblame.py'
    testPath = '~/dev/ua/airship/airship/apps/messages'
    $scope.targetPathInput = testPath

    _targetPathChange(true)
