angular.module(SERVICE_MODULE).service 'Lints', ($rootScope) ->
    class Lints
        issueCount: (lintData) ->
            return lintData.issues.length

    new Lints()
