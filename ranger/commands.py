
# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

from __future__ import (absolute_import, division, print_function)
import os
from ranger.api.commands import Command


class nvim(Command):
    """
    :nvim

    Abre o arquivo ou diretório selecionado no Neovim usando o caminho absoluto.
    """
    def execute(self):
        # Se foi passado um argumento, use-o; caso contrário, tenta usar o arquivo selecionado.
        if self.arg(1):
            target = self.rest(1)
        else:
            try:
                target = self.fm.thisfile.path
            except AttributeError:
                target = self.fm.thisdir.path

        self.fm.notify("Abrindo: " + target)
        # Note o espaço após o caminho absoluto para separar do target
        self.fm.run("/opt/homebrew/bin/nvim " + target)


class my_edit(Command):
    """
    :my_edit

    Comando de exemplo para editar um arquivo.
    """
    def execute(self):
        # Se um argumento foi passado, use-o; caso contrário, use o arquivo selecionado.
        if self.arg(1):
            target_filename = self.rest(1)
        else:
            target_filename = self.fm.thisfile.path

        self.fm.notify("Let's edit the file " + target_filename + "!")
        if not os.path.exists(target_filename):
            self.fm.notify("The given file does not exist!", bad=True)
            return

        self.fm.edit_file(target_filename)

    def tab(self, tabnum):
        return self._tab_directory_content()
