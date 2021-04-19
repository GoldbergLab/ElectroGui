# -*- mode: python ; coding: utf-8 -*-


block_cipher = None


a = Analysis(['IntanNCRead.py'],
             pathex=['C:\\Users\\Brian Kardon\\Dropbox\\Documents\\Work\\Cornell Lab Tech\\Projects\\Zebrafinch\\ElectroGui\\source\\IntanNCRead'],
             binaries=[],
             datas=[('viewTemplate.html', '.')],
             hiddenimports=['cftime'],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)

# # Add static files
# a.datas += [('viewTemplate.html', 'C:\\Users\\Brian Kardon\\Dropbox\\Documents\\Work\\Cornell Lab Tech\\Projects\\Zebrafinch\\ElectroGui\\source\\IntanNCRead', "DATA")]

pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          [],
          exclude_binaries=True,
          name='IntanNCRead',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          icon='icon.ico',
          console=False )
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=False,
               upx=True,
               upx_exclude=[],
               name='IntanNCRead')
