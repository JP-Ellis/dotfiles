#!/bin/zsh

function set-theme {

}

function available_themes {
    themes=$(ls "${0:A:h}")
    themes=(${(M)themes:#})
}

function _set-theme {
    local line
}

available_themes