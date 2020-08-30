from behave import fixture
import subprocess, time

@fixture
def startXFCE4Clipman(context):
    context.xfce4Clipman = subprocess.Popen(['xfce4-clipman'], stdout=subprocess.PIPE)
    yield context.xfce4Clipman.communicate()
    context.xfce4Clipman.terminate()
    time.sleep(1.0)
    context.xfce4Clipman.kill()

@fixture
def startGigolo(context):
    context.gigolo = subprocess.Popen(['gigolo'], stdout=subprocess.PIPE)
    yield context.gigolo.communicate()
    context.gigolo.terminate()
    time.sleep(1.0)
    context.gigolo.kill()