DIDACTOR 2.3

This is the Didactor 2.3 distribution, released on .....

There are two ways to build the software: building it in this directory
based on the 'build.xml' file, or creating a custom build including custom
templates and components. These two processes will be described below.

Note: use Maven 2.1

=== NORMAL BUILD ===

To build the didactor distro, do the following:
- type:
    mvn

This results in a war in distro/target (and in your maven repository).

This war can be deployed like an mmbase war.

=== CUSTOM BUILD ===

- Take the distro/pom.xml as an example, and make something like that for your own site.

- For more complicated sites, with customized 'components' and perhaps 'providers' you can also take
  pom.xml as an example, and a make a build with more stages.


Didactor support 'tree-including' to override virtually any JSP in the components with your own
ones, based on 'providers' and 'educations'.

This can be built using normal maven conventions too:
E.g.:
michiel@mitulo:~/vu/didactor/trunk/providers/vu$ tree -d
.
`-- src
    `-- main
        `-- webapp
            |-- WEB-INF
            |   `-- config
            |       |-- applications
            |       |   |-- Aoc
            |       |   |-- Fobieen
            |       |   `-- Vu
            |       `-- utils
            `-- vu
                |-- aoc
                |   |-- assessment
                |   |-- cockpit
                |   |-- css
                |   `-- img
                |-- aoc_a
                |   |-- assessment
                |   |-- cockpit
                |   |-- css
                |   `-- img
                |-- cockpit
                |-- core
                |   `-- js
                |-- css
                |-- editwizards
                |   `-- assignments
                |-- education
                |   `-- wizards
                |       |-- modes
                |       |   |-- homework
                |       |   `-- repository
                |       |-- new
                |       `-- show
                |-- errorpages
                |-- faq
                |   `-- frontoffice
                |-- fobieen
                |   |-- cockpit
                |   |-- css
                |   `-- img
                |-- gfx
                |-- img
                |-- kupu
                |-- login
                |-- lumen
                |-- mindfulness
                |   |-- cockpit
                |   |-- css
                |   `-- img
                |   `-- style
                |       `-- images
                |-- ms
                |   |-- cockpit
                |   |-- css
                |   |-- img
                |   `-- login
                |-- portalpages
                `-- shared


here for  provider 'vu' and several educations all kind of stuff is overrriden.
This is build as a war overlay and included in the 'vu' didactor distro.
