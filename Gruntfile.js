'use strict';

var grunt = require('grunt');

grunt.loadNpmTasks('grunt-contrib-watch');
grunt.loadNpmTasks('grunt-contrib-coffee');
grunt.loadNpmTasks('grunt-contrib-copy');
grunt.loadNpmTasks('grunt-notify');
grunt.loadNpmTasks('grunt-run');

var env = process.env;

var serverPort = (grunt.option('port') || env.PORT || env.npm_package_config_port);

var NO_SPAWN = {spawn: false};

grunt.initConfig({
  watch: { // Hwat! This task lays out the dependency graph.
    coffee: {
      files: ['src/**', 'templates/**', 'package.json'],
      tasks: [
        'compile',
        'run:test',
        'bundle'
      ],
      options: NO_SPAWN
    },
    umd_consumers: {
      files: ['test/scripts/**'],
      tasks: [
        'run:compile_umd_consumers',
        'notify:build'
      ],
      options: NO_SPAWN
    },
    test: {
      files: ['test/unit/**'],
      tasks: [
        'test'
      ],
      options: NO_SPAWN
    },
    indices: {
      files: ['test/indices/*', 'test/lib/*'],
      tasks: [
        'bundle'
      ],
      options: NO_SPAWN
    },
    less: {
      files: ['less/**'],
      tasks: ['run:lessc'],
      options: NO_SPAWN
    }
  },
  coffee: {
    src: {
      expand: true,
      flatten: false,
      cwd: 'src',
      src: ['**/*.coffee'],
      dest: '.tmp/src',
      ext: '.js'
    }
  },
  copy: {
    js: {
      files: [
        {
          expand: true,
          cwd: '.tmp/src',
          src: ['**'],
          dest: 'build'
        }
      ]
    },
    templates: {
      files: [
        {
          expand: true,
          cwd: 'templates',
          src: ['**'],
          dest: '.tmp/src/templates'
        }
      ]
    }
  },
  run: {
    server: {
      cmd: 'serve',
      args: [
        '--port',
        serverPort
      ],
      options: {
        wait: false
      }
    },
    test: {
      exec: "mocha --compilers coffee:coffee-script/register test/unit/*"
    },
    lessc: {
      exec: "lessc --include-path=less:node_modules less/main.less > dist/main.css"
    },
    bundle_test_indices: {
      cmd: './bin/bundle-test-indices'
    },
    bundle_artifacts: {
      cmd: './bin/bundle-artifacts'
    },
    compile_umd_consumers: {
      cmd: './bin/compile-umd-consumers'
    },
    clean: {
      cmd: './bin/clean'
    },
    inject_version: {
      cmd: './bin/inject-version.js'
    },
    inline_templates: {
      cmd: './bin/inline-templates'
    }
  },
  notify: {
    build: {
      options: {
        title: 'Task Complete',
        message: 'Built test indices'
      }
    },
    less: {
      options: {
        title: 'Task Complete',
        message: 'CSS compiled',
      }
    },
    server: {
      options: {
        message: 'Server is ready!'
      }
    }
  }
});

grunt.registerTask('clean', ['run:clean']);

grunt.registerTask('compile', ['-compile', '-post-compile']);
grunt.registerTask('-compile', ['coffee', 'copy:templates']);
grunt.registerTask('-post-compile', ['run:inject_version', '-inline_templates']);

// Run tests.
grunt.registerTask('test', ['compile', 'run:test']);

// Copy src files to the build dir, and inline the templates.
grunt.registerTask('-inline_templates', ['copy:js', 'run:inline_templates']);

grunt.registerTask('bundle', [
  'run:bundle_artifacts',
  'run:compile_umd_consumers',
  'run:bundle_test_indices',
  'notify:build'
]);

grunt.registerTask('build', [
  'clean',
  'compile',
  'run:lessc',
  'bundle'
]);

grunt.registerTask('build:dist', [
  'clean',
  'compile',
  'run:lessc',
  'run:bundle_artifacts'
]);

grunt.registerTask('serve', [
  'build',
  'run:server',
  'watch'
]);

grunt.registerTask('default', ['build']);
