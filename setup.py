from setuptools import setup
from Cython.Build import cythonize

setup(
	name="MX11",
	ext_modules=cythonize(
		['MX11/MXALU11U.pyx', 'MX11/MXREGS.pyx', 'MX11/MX11SU_type1.pyx'],
		compiler_directives={'language_level': '3'}
	)
)