angular.module(SERVICE_MODULE).service 'Api', ($q, $http, $rootScope) ->
    class Api
        lastUpdate: Date.now()
        pendingPoll: false

        scan: ->
            return 'blah'

        testPath: (path, branchMode=false) ->
            $rootScope.setLoading(true)
            deferred = $q.defer()
            config =
                url: "/api/testpath"
                params:
                    path: path
                method: 'get'
                cache: false
            if branchMode
                console.log 'branchMode:', branchMode
                config.params.branch = branchMode
            request = $http config
            request.success (response) ->
                deferred.resolve response
                $rootScope.setLoading(false)
            deferred.promise

        fullScan: (paths) ->
            $rootScope.setLoading(true)
            @lastUpdate = Date.now()
            deferred = $q.defer()
            pathsParam = paths.join(',')
            request = $http {
                url: "/api/fullscan"
                params:
                    paths: pathsParam
                method: 'get'
                cache: false
            }
            request.success (response) ->
                deferred.resolve response
                $rootScope.setLoading(false)
            deferred.promise

        poll: (paths, branchMode=false, fullScan=false) ->
            deferred = $q.defer()

            if @pendingPoll
                deferred.resolve({})
            else
                @pendingPoll = true
                params =
                    since: @lastUpdate
                    paths: paths.join(',')
                    branch: branchMode
                if fullScan
                    params.fullScan = true

                request = $http {
                    url: '/api/poll'
                    method: 'get'
                    params: params
                    cache: false
                }

                request.success (response) =>
                    if not _.isEmpty response
                        @lastUpdate = Date.now()
                    deferred.resolve response
                    @pendingPoll = false

            return deferred.promise

    new Api()
