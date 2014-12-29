git-peek-menu v0.1
==================

What is it?
-----------
The git-peek-menu.app is a simple status bar menu that helps you keep track of your local git repositories and assists with helper functions to get latest changes and do some build tasks.

<img src="../master/docs/sample.png?raw=true" alt="sample" width="500" height="475"/>

Features
--------
* shows local changes to your repository: **untracked**, **modified**, **staged** files
* displays current **branch** and **revision**
* displays **commits behind** and **commits ahead** of remote repository
* if enabled shows **pull button** in menu which pulls remote changes if no merge is expected
* add **custom build** command to a project to do any command line commands your project may needs e.x:<br />``cd /home/vagrant && vagrant ssh -c 'cd /some/project && ant'``
* works with dark theme

Requirements
------------
 * OSX 10.10 or newer
 * the pull/fetch features rely on the remote branch tracking of your local git repo like:<br />``git branch --set-upstream-to=origin/develop develop``

Todos
-----
* refactor some stuff against best practice
* fix inline todo comments, find out whats going wrong there
* remove boilerplate code and de duplicate code
* maybe switch from obj-c to swift
* make a better UI to fit apple human interface guidelines, fancy icons ;-)
* add core data versioning and migrations, current workaround:<br />``rm ~/Library/Application\ Support/cfuerst.git_peek_menu/OSXCoreDataObjC.storedata``
