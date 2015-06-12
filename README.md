# Ginatra

Ginatra displays real-time visualization of your git repositories, using Sinatra, ReactJs and ChartJs.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc/generate-toc again -->
**Table of Contents**

- [Ginatra](#ginatra)
- [Setup](#setup)
- [Configurations](#configurations)
- [Threshold](#threshold)
- [Usage](#usage)
- [Developing](#developing)
- [Todos](#todos)

<!-- markdown-toc end -->

# Setup

From the app's root directory:

    bundle install
    npm install

Ginatra is using ```browserify``` and ```watchify``` to compile all js dependencies into a single file.

Compile the ```bundle.js``` file that will be used by the app:

    npm run build

Next, add some local repositories to the ```config.yml``` file

Create a ```data``` folder in the app root directory and make sure it is writable.

Copy ```config.sample.yml``` to ```config.yml``` file in the app root directory.

# Configurations

Add some repositories on your local installation to ```config.yml```:

    # All of your repositories should be listed here
    # repo_id should be unique and only use "_" (underscore)
    # if needed. This is because "-" will break javascript later on

    repositories:
        repo_id_1:
            path: /path/to/your/repo_1
            name: Repository 1 Name
        repo_id_2:
            path: /path/to/your/repo_2
            name: Repository 2 Name


    # This is the default color swatch.
    # The color order in the array matches the repo_id order.
    # Example: repo_id_1: #ce0000 and repo_id_2: #114b5f.
    # Colors will rotate from the beginning if there are
    # more repositories than colors.

    colors: ['#ce0000','#114b5f','#f7d708','#028090','#9ccf31',
             '#ff9e00','#e4fde1','#456990','#ff9e00','#f45b69']


    # threshold value (in hours) is used to estimate the hours
    # developers have put into the project. More detail in the
    # threshold section.

    threshold: 3


    # Sprint settings is used if you would like to
    # visualize a part of the data based on sprint slots.
    # - period: number of days in a sprint.
    # - reference_date: any date that is considered the
    # start of a sprint. Ginatra will figure out the sprint
    # end and start dates that the current date is between.

    sprint:
        period: 14
        reference_date: 4 July 2015

# Threshold

Assuming threshold is set to 3 hours, any 2 commits by the same author that are less than 3 hours apart are considered a development section, so the time difference is added to the session.

The time keeps adding on until the next commit is more than 3 hours away from the current commit. At that point, we assume the developer has moved on to a new development blocks and the session time restarts.

To compensate for the time leading to the first commit, 3 hours are added to that period.

# Usage

Once you have added your repositories, start the ```Unicorn``` server from the app root directory:

    mr-sparkle config.ru

The dashboard can now be accessed at ```http://localhost:8080```

mr-sparkle will also watch the file changes in Ginatra so you don't need to restart the server frequently when developing.

# Developing

Currently I am using separate jsx component files for the dashboard. If you want to make changes or add new js code, run

    npm run watch

Component files are in ```assets/js/``` folder. Only the compiled ```bundle.js``` file is being loaded on the page.

Details on API and class extensions to be added...


# Todos

- Tests!
- Use websockets instead of constantly sending ajax requests.
- Refactor into a gem
- Setup ```config.yml``` and ```data``` folder automatically.
- API for author info
