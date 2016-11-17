_exists()
{
  # take array check words for it
  for word in $1
  do
    if [[ $word == $2 ]]; then
      return 0
    fi
  done
  return 1
}

# takes in an array of words $1 removed $2 from it and echos the result
#_word_intersection()
#{
  local return_array=()
  for word in $1
  do
    if [[ $(_exists $word) -ne 0 ]]; then
      return return_array+=("$word")
    fi
  done
  echo "${return_array[*]}

#}

_get_orgs()
{
  echo "$(cf orgs | awk 'NR>3' | tr '\n' ' ')"
}

_get_spaces()
{
  echo "$(cf spaces | awk 'NR>3' | tr '\n' ' ')"
}

# $1 take in list string space delimited words
# $2 take in current word
_compgen()
{
  COMPREPLY=( $(compgen -W "$1" -- $2) )
}

_app()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[COMP_CWORD-1]}

  if [[ "$cur" == -* ]]; then
    _compgen "--guid" $cur
    return 0
  fi

  # autocomplete with orgs from cf command
  if [[ "$prev" == "app" || "$prev"  ]]; then
    _compgen "$(cf apps | awk 'NR>3' | tr '\n' ' ')" $cur
    # COMPREPLY=( $(compgen -W "$(cf apps | awk 'NR>3' | tr '\n' ' ')" -- $cur) )
    return 0
  fi
}

_org()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[COMP_CWORD-1]}

  # already specified a specific org, autocomplete for the --guid flag
  if [[ "$cur" == -* ]]; then
    _compgen "--guid" $cur
    return 0
  fi

  # autocomplete with orgs from cf command
  if [[ "$prev" != "org" ]]; then
    _compgen "$(_get_orgs)" $cur
    return 0
  fi
}

_target()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[COMP_CWORD-1]}

  all_flags="-o -s"

  if [[ "$prev" == -o ]]; then
    _compgen "$(_get_orgs)" $cur
    return 0
  elif [[ "$prev" == -s ]]; then
    _compgen "$(_get_spaces)" $cur
    return 0
  else
    # check for -o and -s
    if [[ $(_exists ${COMP_WORDS[*]} "-o") -ne 0 ]]; then
      _compgen "-s" $cur
      return 0
    elif [[ $(_exists ${COMP_WORDS[*]}" -s") -ne 0 ]]; then
      _compgen "-o" $cur
      return 0
    else
      _compgen "-o -s" $cur
      return 0
    fi
    return 0
  fi
}

_cf()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[COMP_CWORD-1]}

  case ${COMP_WORDS[1]} in
    login)
      _compgen "--skip-ssl-validation -a -u -p -o -s --sso --help" $cur
      return 0
      ;;
    logout|passwd|orgs)
      _compgen "--help"
      return 0
      ;;
    auth)
      _compgen "--unset --skip-ssl-validation" $cur
      return 0
      ;;
    app)
      _app
      return 0
      ;;
    org)
      _org
      return 0
      ;;
    org-users)
      _compgen "$(_get_orgs)" $cur
      return 0
      ;;
    target)
      _target
      return 0
      ;;
  esac

  if [[ $COMP_CWORD -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "help login logout passwd target api auth apps app push scale delete rename start stop restart restage restart-app-instance events files logs env set-env unset-env stacks stack copy-source create-app-manifest get-health-check set-health-check enable-ssh disable-ssh ssh-enabled ssh marketplace services service create-service update-service delete-service rename-service create-service-key service-keys service-key delete-service-key bind-service unbind-service create-user-provided-service update-user-provided-service orgs org create-org delete-org rename-org spaces space create-space delete-space rename-space allow-space-ssh disallow-space-ssh space-ssh-allowed domains create-domain delete-domain create-shared-domain delete-shared-domain routes create-route check-route map-route unmap-route delete-route delete-orphaned-routes router-groups buildpacks create-buildpack update-buildpack rename-buildpack delete-buildpack create-user delete-user org-users set-org-role unset-org-role space-users set-space-role unset-space-role quotas quota set-quota create-quota delete-quota update-quota share-private-domain unshare-private-domain space-quotas space-quota create-space-quota update-space-quota delete-space-quota set-space-quota unset-space-quota service-auth-tokens create-service-auth-token update-service-auth-token delete-service-auth-token service-brokers create-service-broker update-service-broker delete-service-broker rename-service-broker migrate-service-instances purge-service-offering purge-service-instance service-access enable-service-access disable-service-access security-group security-groups create-security-group update-security-group delete-security-group bind-security-group unbind-security-group bind-staging-security-group staging-security-groups unbind-staging-security-group bind-running-security-group running-security-groups unbind-running-security-group running-environment-variable-group staging-environment-variable-group set-staging-environment-variable-group set-running-environment-variable-group feature-flags feature-flag enable-feature-flag disable-feature-flag curl config oauth-token ssh-code add-plugin-repo remove-plugin-repo list-plugin-repos repo-plugins plugins install-plugin uninstall-plugin dev --version -v --build -b --help -h" -- $cur) )
  fi
}
complete -F _cf cf
