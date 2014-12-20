var grunt = require('grunt');

grunt.initConfig({
  watch: {
    src: {
      files: ['src/**/*', 'templates/**/*'],
      tasks: ['compile'],
      options: {spawn: false}
    },
    gen: {
      files: ['.tmp/src/**/*'],
      tasks: ['post-compile'],
      options: {spawn: false}
    },
    build: {
      files: ['build/**/*'],
      tasks: ['bundle'],
      options: {spawn: false}
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
    templates: {
      files: [
        {expand: true, cwd: 'templates/', src: ['**'], dest: '.tmp/src/'}
      ]
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
        title: 'Task Complete',  // optional
        message: 'CSS compiled', //required
      }
    },
    server: {
      options: {
        message: 'Server is ready!'
      }
    }
  }
});

grunt.loadNpmTasks('grunt-notify');
grunt.loadNpmTasks('grunt-contrib-watch');
grunt.loadNpmTasks('grunt-contrib-coffee');
grunt.loadNpmTasks('grunt-contrib-copy');

grunt.registerTask('compile', ['coffee', 'copy:templates']);
