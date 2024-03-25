Unpack tar.gz installers here.

Symlinks would work here for the components Server, Portal, Datastore
because these are mounted at run time
but not for the geometry library, because of the COPY in Dockerfile