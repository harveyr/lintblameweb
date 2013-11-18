app = angular.module(APP_NAME, [
    "#{APP_NAME}.services"
    "#{APP_NAME}.directives"
]).run ($rootScope, Api, Lints) ->
    $rootScope.appName = "lintblame"

    $rootScope.lintResults = {}

    spinOpts =
        lines: 10, # The number of lines to draw
        length: 5, # The length of each line
        width: 2, # The line thickness
        radius: 5, # The radius of the inner circle
        corners: 1, # Corner roundness (0..1)
        rotate: 0, # The rotation offset
        direction: 1, # 1: clockwise, -1: counterclockwise
        color: '#fff', # #rgb or #rrggbb or array of colors
        speed: 1, # Rounds per second
        trail: 60, # Afterglow percentage
        shadow: false, # Whether to render a shadow
        hwaccel: false, # Whether to use hardware acceleration
        className: 'spinner', # The CSS class to assign to the spinner
        zIndex: 2e9, # The z-index (defaults to 2000000000)
        top: '5px', # Top position relative to parent in px
        left: '-20px' # Left position relative to parent in px
    $rootScope.loadingSpinner = new Spinner(spinOpts)
    $rootScope.isSpinning = false
    $rootScope.setLoading = (val) ->
        if val
            if !$rootScope.isSpinning
                target = document.getElementById 'loading'
                $rootScope.loadingSpinner.spin(target)
        else
            $rootScope.loadingSpinner.stop()
        

    $rootScope.activePaths = ->
        if not $rootScope.lintResults
            return []
        return _.keys $rootScope.lintResults

    $rootScope.updateResults = (pathsAndData) ->
        for path, data of pathsAndData
            Lints.issueCount data
            $rootScope.lintResults[path] = data

        paths = _.keys $rootScope.lintResults
        $rootScope.sortedPaths = paths.sort (a, b) ->
            return Lints.issueCount($rootScope.lintResults[b]) - Lints.issueCount($rootScope.lintResults[a])

        now = new Date()
        lastRefresh = now.getHours() + ':'
        mins = now.getMinutes()
        if mins < 10
            lastRefresh += '0'
        lastRefresh += mins + ':'
        secs = now.getSeconds()
        if secs < 10
            lastRefresh += '0'
        lastRefresh += secs
        $rootScope.lastRefresh = lastRefresh


