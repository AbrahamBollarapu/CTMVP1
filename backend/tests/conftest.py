import sys, os

# location of this conftest
here = os.path.dirname(__file__)

# absolute path to auth/src/app
app_src = os.path.abspath(os.path.join(here, "..", "auth", "src", "app"))

# insert it at front so "import main" works
if os.path.isdir(app_src) and app_src not in sys.path:
    sys.path.insert(0, app_src)
