# Ginatra

[![Build Status](https://travis-ci.org/nathandao/ginatra.svg?branch=master)](https://travis-ci.org/nathandao/ginatra)
[![Code Climate](https://codeclimate.com/github/nathandao/ginatra/badges/gpa.svg)](https://codeclimate.com/github/nathandao/ginatra)
[![Test Coverage](https://codeclimate.com/github/nathandao/ginatra/badges/coverage.svg)](https://codeclimate.com/github/nathandao/ginatra/coverage)

Ginatra is a Sinatra app that provides a web API for git repositories. Updates of new commits are streamed through an em-websocket server.

There is also a front-end dashboard that comes with the package built with ReacJs and ChartJS to display real-time visualization of your git repos.

## Features:
- All repos are stored and accessed locally.
- Quick setup. No database required.
- Intuitive API to get repo data. Example: ```/commits?by=AuthorName&in=RepoName&from=2 days ago&til=2 hours ago```
- Data is abstracted from any info available in the commit data including commits, authors, dates, line changes.
- Calculation of estimated time based on the commit time of each authors.
- Realtime updates of repo changes through websocket.
- Provides a default super cool looking dashboard built with ReactJs and ChartJs, althought you can always build a custom front-end with data from the API.

## Requirement:
- npm : to build the bundled javascript used in the demo Dashboard.

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

    title: Your dashboard title

    repositories:
        repo_id_1:
            path: /path/to/your/repo_1
            name: Repository 1 Name
        repo_id_2:
            path: /path/to/your/repo_2
            name: Repository 2 Name

    # The interval at wich you would like the server to check of updates
    # on the git repos
    update_interval: 60s

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

Once you have added your repositories start the app server from the app root directory:

```
bundle exec rackup
```
or run in production mode:
```
bundle exec rackup -E production
```

The dashboard can now be accessed at ```http://127.0.0.1:8080```
The websocket server can be connected to at ```ws://127.0.0.1:9290```.

# Developing

Currently I am using separate jsx component files for the dashboard. If you want to make changes or add new js code, run

    npm run watch

Component files are in ```assets/js/``` folder. Only the compiled ```bundle.js``` file is being loaded on the page.

# Using the API

Get commits:

    /stat/repo_list

returns

    ["repo_1", "repo_2", "repo_3"]

List all repository ids

    /start/hours

returns

    {
        "repo_1": [
            {
                "author": "Foo",
                "hours": 900.123
            },
            {
                "author": "Bar",
                "hours": 800.123
            }
        ],
        "repo_2": [
            {
                "author": "Foo",
                "hours": 900.123
            },
            {
                "author": "Bar",
                "hours": 800.123
            }
        ]
    }

```repository``` class is the only class with instance methods handling retrieving and storing of commits json data, from which other classes get data from.

# Todos

- Provides options for diffrent servers support. Currently only works with Rainbows
- Install scripts to setup ```config.yml``` and ```data``` folder automatically.
- Web API for author info (Name, email, ...)
