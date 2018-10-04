These scripts are intended to help users interact with the [SCEC SEAS Benchmark
Comparison Tool](http://scecdata.usc.edu/cvws/cgi-bin/seas.cgi)

Use these scripts at your own risk. I did not design the website, and make not
guarantees about there correctness or that they won't do something terrible to
your data.

All scripts when run without argument will give basic usage.

# `scec_seas_validate_login.pl`

Validates the username, password, and problem number.

Can also be used to validate the user has a given version number initialized for
a given problems

# `scec_seas_upload_data.pl`

Upload data to the website for a given problem (and optional version number)

This script assumes that data files match the name fields of the website, i.e.,
a fault station on the free surface would be `$(prefix)fltst_dp000$(postfix)`
where prefix and postfix are custom to the user (see script usage)

# `scec_seas_delete_data.pl`

Delete user data from the website for a given problem number (and optional
version number)

# `scec_seas_download_data.pl`

Download a select users data (can be used to download your data or others)

# `scec_seas_download_images.pl`

Download all the image files for a user or set of users
