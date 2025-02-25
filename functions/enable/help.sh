#!/bin/bash


enable_help() {
    echo -e "${bold}Enable Handler${reset}"
    echo -e "${bold}-------------${reset}"
    echo -e "${blue}heavyscript enable | ${blue}[FEATURE]${reset}"
    echo
    echo -e "${bold}Description${reset}"
    echo -e "${bold}-----------${reset}"
    echo -e "    Enable specific locked down functions in Truenas SCALE."
    echo
    echo -e "${bold}FEATURES${reset}"
    echo -e "${bold}-------${reset}"
    echo -e "${blue}--api${reset}"
    echo -e "    Enables external access to the Kubernetes API server"
    echo -e "${blue}--apt${reset}"
    echo -e "    Enable apt, apt-get, and apt-key."
    echo -e "${blue}--helm${reset}"
    echo -e "    Enable helm commands."
    echo -e "${blue}-h, --help${reset}"
    echo -e "    Show this help message and exit."
    echo
    echo -e "${bold}Example${reset}"
    echo -e "${bold}-------${reset}"
    echo -e "    ${blue}heavyscript enable --api${reset}"
    echo -e "    ${blue}heavyscript enable --apt${reset}"
    echo
}