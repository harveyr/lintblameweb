angular.module(APP_NAME).controller 'MenuCtrl', ($scope, $rootScope, $q, Api) ->
    $rootScope.branchMode = false
    $scope.showSubmitBtn = true

    $scope.poll = ->
        if $scope.pollInterval
            clearInterval($scope.pollInterval)

        $scope.pollInterval = setInterval ->
            paths = $rootScope.activePaths()
            if paths.length > 0
                Api.poll($rootScope.targets).then (response) ->
                    if not _.isEmpty response
                        $rootScope.updateResults response
        , 2000

    $scope.acceptPath = ->
        if !$rootScope.targets or $rootScope.targets.length == 0
            return
        $scope.showSubmitBtn = false
        Api.fullScan($rootScope.targets).then (response) ->
            $rootScope.updateResults response
            $scope.poll()

    _testPath = (andAccept=false) ->
        deferred = $q.defer()
        path = $scope.targetPathInput
        Api.testPath(path, $rootScope.branchMode).then (response) ->
            $scope.pathExists = response.exists
            $rootScope.targets = response.targets

            console.log 'response.vcs:', response.vcs
            if not _.isUndefined response.vcs
                $scope.vcs = response.vcs
                $scope.branch = response.branch
                $rootScope.vcsName = response.name

            if andAccept
                $scope.acceptPath()
            deferred.resolve()
        deferred.promise

    _targetPathChange = ->
        path = $scope.targetPathInput
        if path
            $scope.showSubmitBtn = true
            _testPath()
    $scope.targetPathChange = _.throttle(_targetPathChange, 1000)

    $scope.toggleBranchMode = ->
        $rootScope.branchMode = !$rootScope.branchMode
        _testPath(true)


    # testing
    # $scope.targetPathInput = '/Users/harveyrogers/dev/lintblameweb/app/webapp/endpoints/routes.py'
    # $scope.targetPathInput = '/Users/harveyrogers/dev/lintblame/lintblame.py'
    testPath = '~/dev/ua/airship/airship/apps/messages'
    $scope.targetPathInput = testPath
    _testPath(true)
