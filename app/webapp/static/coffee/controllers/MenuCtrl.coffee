angular.module(APP_NAME).controller 'MenuCtrl', ($scope, $rootScope, $q, Api) ->
    $rootScope.branchMode = false
    $scope.showSubmitBtn = true
    $scope.pollCount = 0

    _testPath = (andAccept=false) ->
        deferred = $q.defer()
        path = $scope.targetPathInput
        Api.testPath(path, $rootScope.branchMode).then (response) ->
            $scope.pathExists = response.exists
            $scope.targets = response.targets

            if not _.isUndefined response.vcs
                $scope.vcs = response.vcs
                $scope.branch = response.branch
                $rootScope.vcsName = response.name

            if andAccept
                $scope.acceptPath()
            deferred.resolve()
        deferred.promise

    $scope.poll = ->
        if $scope.pollInterval
            clearInterval($scope.pollInterval)

        $scope.pollInterval = setInterval ->
            paths = $rootScope.activePaths()
            if paths.length > 0
                if $scope.pollCount > 0 and $scope.pollCount % 10 == 0
                    # Update everything
                    _testPath(true)
                else           
                    Api.poll($rootScope.lintPaths()).then (response) ->
                        if not _.isEmpty response
                            $rootScope.updateResults response
                $scope.pollCount += 1
        , 2000

    $scope.acceptPath = ->
        if !$scope.targets or $scope.targets.length == 0
            return
        $scope.showSubmitBtn = false
        Api.fullScan($scope.targets).then (response) ->
            $rootScope.updateResults response
            $scope.poll()

    _targetPathChange = ->
        path = $scope.targetPathInput
        if path
            $scope.showSubmitBtn = true
            _testPath()
    $scope.targetPathChange = _.throttle(_targetPathChange, 1000)

    $scope.toggleBranchMode = ->
        $rootScope.branchMode = !$rootScope.branchMode
        _testPath(true)


    # Testing:
    # $scope.targetPathInput = '/Users/harveyrogers/dev/lintblameweb/app/webapp/endpoints/routes.py'
    # $scope.targetPathInput = '/Users/harveyrogers/dev/lintblame/lintblame.py'
    testPath = '~/dev/ua/airship/airship/apps/messages'
    $scope.targetPathInput = testPath
    _testPath(true).then ->
        if $scope.branch
            $scope.toggleBranchMode()
