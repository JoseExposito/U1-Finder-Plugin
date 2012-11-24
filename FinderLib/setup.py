from setuptools import setup

setup(
      name='FinderLib',
      plugin = ['FinderLib.py'],
      options=dict(py2app=dict(extension='.bundle'))
)