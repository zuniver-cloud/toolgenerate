import os
import platform
import shutil
import zipfile
import time

separator = ''
classpath_semicolon = ''
if platform.system() == 'Windows':
    separator = '\\'
    classpath_semicolon = ';'
else:
    separator = '/'
    classpath_semicolon = ':'

libdir = '.{0}tempResources{0}templib'.format(separator)
toollibdir = '.{0}lib'.format(separator)
srcdir = '.{0}src'.format(separator)
outdir = '.{0}out'.format(separator)

def compile_project():
    jars = []
    srcs = []

    for f in os.listdir(libdir):
        if f.endswith('.jar'):
            jars.append(libdir + separator + f)

    for f in os.listdir(toollibdir):
        if f.endswith('.jar'):
            jars.append(toollibdir + separator + f)

    for dir in os.walk(srcdir):
        if len(dir[2]) > 0:
            for f in dir[2]:
                if f.endswith('.java'):
                    srcs.append(dir[0] + separator + f)

    classpath = outdir
    for jar in jars:
        classpath += classpath_semicolon + jar

    sources = ''
    for java in srcs:
        sources += '"' + java + '" '

    if os.path.exists('out'):
        shutil.rmtree('out')
    
    os.mkdir('out')

    cmd = 'javac -encoding UTF-8 -implicit:none -cp "{0}" -d "{1}" {2}'.format(classpath, outdir, sources)
    print(cmd)
    os.system(cmd)


def zip_dir(dirname, zipfilename):
    filelist = []
    if os.path.isfile(dirname):
        filelist.append(dirname)
    else :
        for root, dirs, files in os.walk(dirname):
            for name in files:
                filelist.append(os.path.join(root, name))
        
    zf = zipfile.ZipFile(zipfilename, "w", zipfile.zlib.DEFLATED)
    for tar in filelist:
        arcname = tar[len(dirname):]
        zf.write(tar,arcname)


def package_project():
    webrootdir = '.' + separator + 'WebRoot'
    resourcedir = webrootdir + separator + 'resource'
    shutil.copytree(resourcedir + separator + 'css', outdir + separator + 'css')
    shutil.copytree(resourcedir + separator + 'js', outdir + separator + 'js')
    shutil.copytree(resourcedir + separator + 'images', outdir + separator + 'images')
    shutil.copytree(webrootdir + separator + 'WEB-INF' + separator + 'pages', outdir + separator + 'pages')
    shutil.copyfile(srcdir + separator + 'config.xml', outdir + separator + 'config.xml')
    shutil.copytree('.' + separator + 'lib', outdir + separator + 'lib')
    if os.path.exists(resourcedir + separator + 'other'):
        shutil.copytree(resourcedir + separator + 'other', outdir + separator + 'other')

    if os.path.exists('tool.jar'):
        os.remove('tool.jar')

    print(outdir)
    zip_dir(outdir, 'tool.jar')

if __name__ == "__main__":
    compile_project()
    package_project()
    pass