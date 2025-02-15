let environment = {
  plugins: [
    require('postcss-easy-import'),
    require('tailwindcss'),
    require('postcss-nested'),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    })
  ]
}

if (process.env.RAILS_ENV === 'production') {
  environment.plugins.push(
    require('@fullhuman/postcss-purgecss')({
      content: [
        './app/**/*.erb',
        './app/javascript/**/*.css',
        './app/javascript/**/*.js',
        './app/components/**/*.erb',
        './app/components/**/*.css',
        './app/components/**/*.js'
      ],
      defaultExtractor: content => content.match(/[A-Za-z0-9-_:/]+/g) || []
    })
  )
}

module.exports = environment
