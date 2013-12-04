app = angular.module(APP_NAME, [
    "#{APP_NAME}.services"
    "#{APP_NAME}.directives"
]).run ($rootScope, Api, Lints, LocalStorage) ->
    $rootScope.appName = "lintblame"

    $rootScope.lintResults = {}

    LocalStorage.initIfNecessary()

    $rootScope.loadingSpinner = new Spinner({
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
        top: '0', # Top position relative to parent in px
        left: '0' # Left position relative to parent in px    
    })
    $rootScope.isLoading = false
    
    $rootScope.setLoading = (val) ->
        if val
            if !$rootScope.isLoading
                target = document.getElementById 'loading'
                $rootScope.loadingSpinner.spin(target)
        else
            $rootScope.loadingSpinner.stop()
        $rootScope.isLoading = val

    $rootScope.activePaths = ->
        if not $rootScope.lintBundle.fullPath
            return []
        return _.keys $rootScope.lintBundle.lints

    updateFavicon = ->
        count = 0
        for path, data of $rootScope.lintResults
            count += Lints.issueCount(data)
        
        # canvas = document.createElement('canvas')
        # img = document.createElement('img')
        # link = document.getElementById('favicon').cloneNode(true)
        # if canvas.getContext
        #     canvas.height = canvas.width = 16 # set the size
        #     ctx = canvas.getContext '2d'
        #     img.onload = ->
        #         ctx.drawImage(this, 0, 0)
        #         ctx.font = 'bold 10px "helvetica", sans-serif'
        #         ctx.fillStyle = '#F0EEDD'
        #         ctx.fillText(count, 2, 12);
        #         link.href = canvas.toDataURL 'image/png'
        #         document.body.appendChild link

        #   img.src = 'image.png';

    $rootScope.updateResults = (pathsAndData) ->
        console.log 'pathsAndData:', pathsAndData
        for path, data of pathsAndData
            $rootScope.lintBundle.lints[path] = data

        paths = _.keys $rootScope.lintBundle.lints
        $rootScope.sortedPaths = paths.sort (a, b) ->
            return (
                $rootScope.lintBundle.lints[b].modtime -
                $rootScope.lintBundle.lints[a].modtime
            )

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

    $rootScope.resetLintBundle = ->
        $rootScope.lintBundle = {
            lints: {}
            branchMode: false
        }
        $rootScope.sortedPaths = []

    $rootScope.saveCurrentBundle = ->
        LocalStorage.saveLintBundle $rootScope.lintBundle

    $rootScope.updateLintBundle = (properties) ->
        console.log 'updatelintbundle properties:', properties
        for key, value of properties
            $rootScope.lintBundle[key] = value
        $rootScope.saveCurrentBundle()

    # LocalStorage.resetAppStorage()
