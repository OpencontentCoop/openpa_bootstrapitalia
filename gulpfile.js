var
    gulp = require('gulp'),
    sass = require('gulp-sass'),
    touch = require('gulp-touch-cmd');

// source and distribution folder
var
    source = 'src/',
    dest = 'design/bootstrapitalia/';

var bootstrapItaliaSrc = {
    in: './node_modules/bootstrap-italia/src/'
};

var fontAwesomeSrc = {
    in: './node_modules/font-awesome/'
};

var bootstrapItaliaDist = {
    in: './node_modules/bootstrap-italia/dist/'
};

var fonts = {
    in: [source + 'fonts/*.*', bootstrapItaliaSrc.in + 'fonts/**/*', fontAwesomeSrc.in + 'fonts/*.*'],
    out: dest + 'fonts/'
};

var js = {
    in: [
        source + 'js/*.*',
        bootstrapItaliaDist.in + 'js/*.*',
        './node_modules/jquery/dist/jquery.js',
        './node_modules/popper.js/dist/umd/popper.js',
        './node_modules/owl.carousel/dist/owl.carousel.js',

    ],
    out: dest + 'javascript/'
};

var svg = {
    in: [source + 'svg/*.*', bootstrapItaliaDist.in + 'svg/*.*'],
    out: dest + 'images/svg/'
};

var assets = {
    in: [source + 'assets/*.*', bootstrapItaliaDist.in + 'assets/*.*'],
    out: dest + 'images/assets/'
};

var css = {
    in: source + 'scss/**/*',
    out: dest + 'stylesheets/',
    watch: source + 'scss/**/*',
    sassOpts: {
        outputStyle: 'nested',
        precision: 8,
        errLogToConsole: true,
        includePaths: [bootstrapItaliaSrc.in + 'scss', fontAwesomeSrc.in + 'scss']
    }
};

gulp.task('fonts', function () {
    return gulp
        .src(fonts.in)
        .pipe(gulp.dest(fonts.out))
        .pipe(touch());
});


// compile scss
gulp.task('sass', function () {
    return gulp.src(css.in)
        .pipe(sass(css.sassOpts).on('error', sass.logError))
        .pipe(gulp.dest(css.out))
        .pipe(touch());
});

gulp.task('js', function () {
    return gulp
        .src(js.in)
        .pipe(gulp.dest(js.out))
        .pipe(touch());
});

gulp.task('svg', function () {
    return gulp
        .src(svg.in)
        .pipe(gulp.dest(svg.out))
        .pipe(touch());
});

gulp.task('assets', function () {
    return gulp
        .src(assets.in)
        .pipe(gulp.dest(assets.out))
        .pipe(touch());
});

gulp.task(
    'default',
    gulp.series(
        'fonts',
        'sass',
        'js',
        'svg',
        'assets'
    )
);