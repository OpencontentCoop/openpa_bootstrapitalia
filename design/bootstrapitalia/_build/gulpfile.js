// @see https://github.com/andydkcat/customize-bootstrap-sass

const
    gulp = require('gulp'),
    sass = require('gulp-sass'),
    touch = require('gulp-touch-cmd'),
    sourcemaps = require('gulp-sourcemaps'),
    rename = require('gulp-rename'),
    concat = require('gulp-concat'),
    uglify = require('gulp-uglify'),
    babel = require('gulp-babel'),
    replace = require('gulp-replace'),
    header = require('gulp-header'),
    footer = require('gulp-footer'),
    pkg = require('./package.json');

// source and distribution folder
const
    source = 'src/',
    dest = '../',
    standardDest = 'design/standard/';

const bootstrapItaliaSrc = {
    in: './node_modules/bootstrap-italia/'
};

const fontAwesomeSrc = {
    in: './node_modules/font-awesome/'
};

const fonts = {
    in: [source + 'fonts/*.*', bootstrapItaliaSrc.in + 'src/fonts/**/*', fontAwesomeSrc.in + 'fonts/*.*'],
    out: dest + 'fonts/'
};

const js = {
    in: [source + 'js/*.*'],
    deps: [
        //'./node_modules/jquery/dist/jquery.js',
        source + 'js/jquery.js',
        './node_modules/popper.js/dist/umd/popper.js',
        './node_modules/owl.carousel/dist/owl.carousel.js',
    ],
    source: [
        './node_modules/bootstrap/dist/js/bootstrap.js',
        './node_modules/bootstrap-select/js/bootstrap-select.js',
        './node_modules/bootstrap-select/js/i18n/defaults-it_IT.js',
        './node_modules/svgxuse/svgxuse.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/polyfills/array.from.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/circular-loader/CircularLoader-v1.3.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/datepicker/locales/it.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/datepicker/datepicker.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/i-sticky/i-sticky.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/sticky-header.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/ie.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/fonts-loader.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/autocomplete.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/back-to-top.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/componente-base.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/cookiebar.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/dropdown.js',
        //bootstrapItaliaSrc.in + 'src/js/plugins/forms.js',
        source + 'js/forms.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/track-focus.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/forward.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/navbar.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/navscroll.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/sticky-wrapper.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/history-back.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/notifications.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/upload.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/progress-donut.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/list.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/imgresponsive.js',
        //bootstrapItaliaSrc.in + 'src/js/plugins/timepicker.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/input-number.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/carousel.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/transfer.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/select.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/rating.js',
        bootstrapItaliaSrc.in + 'src/js/plugins/dimmer.js',
        bootstrapItaliaSrc.in + 'src/js/bootstrap-italia.js',
    ],
    out: dest + 'javascript/',
};

const svg = {
    in: [source + 'svg/*.*', bootstrapItaliaSrc.in + 'dist/svg/*.*'],
    out: standardDest + 'images/svg/'
};

const assets = {
    in: [source + 'assets/*.*', bootstrapItaliaSrc.in + 'dist/assets/*.*'],
    out: dest + 'images/assets/'
};

const css = {
    in: source + 'scss/**/*',
    out: dest + 'stylesheets/',
    watch: source + 'scss/**/*',
    sassOpts: {
        sourceComments: false,
        outputStyle: 'compressed',
        precision: 8,
        errLogToConsole: true,
        includePaths: [bootstrapItaliaSrc.in + 'src/scss', fontAwesomeSrc.in + 'scss']
    }
};

const jqueryCheck =
    "if (typeof jQuery === 'undefined') {\n" +
    "  throw new Error('Bootstrap\\'s JavaScript requires jQuery. jQuery must be included before Bootstrap\\'s JavaScript.')\n" +
    '}\n';

const jqueryVersionCheck =
    '+function ($) {\n' +
    "  var version = $.fn.jquery.split(' ')[0].split('.')\n" +
    '  if ((version[0] < 2 && version[1] < 9) || (version[0] == 1 && version[1] == 9 && version[2] < 1) || (version[0] >= 4)) {\n' +
    "    throw new Error('Bootstrap\\'s JavaScript requires at least jQuery v1.9.1 but less than v4.0.0')\n" +
    '  }\n' +
    '}(jQuery);\n\n';

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

gulp.task('js-deps', function () {
    return gulp
        .src(js.deps)
        .pipe(gulp.dest(js.out))
        .pipe(touch());
});

gulp.task('js-min', () => {
    return gulp
        .src(js.source)
        .pipe(concat('app.js'))
        .pipe(sourcemaps.init())
        .pipe(replace(/^(export|import).*/gm, ''))
        .pipe(
            babel({
                compact: true,
                presets: [
                    [
                        '@babel/env',
                        {
                            modules: false,
                            loose: true,
                            exclude: ['transform-typeof-symbol'],
                        },
                    ],
                ],
                plugins: ['@babel/plugin-proposal-object-rest-spread'],
            })
        )
        .pipe(uglify())
        .pipe(
            header(
                jqueryCheck +
                '\n' +
                jqueryVersionCheck +
                '\n+function () {\n',
                {pkg: pkg}
            )
        )
        .pipe(footer('\n}();\n'))
        .pipe(
            rename({
                suffix: '.min',
            })
        )
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest(js.out))
        .pipe(touch())
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
    'js',
    gulp.series(
        'js-min',
        'js-deps'
    )
);

gulp.task(
    'default',
    gulp.series(
        'fonts',
        'sass',
        'js-min',
        'js-deps',
        'svg',
        'assets'
    )
);

gulp.task('watch', function () {
    gulp.watch(css.in, gulp.series('sass'));
    gulp.watch(js.in, gulp.series('js-min'));
});