<!--
  Skills in this directory are the canonical copies; ~/.pi/agent/skills/<name>
  are symlinks into here so dotfiles stays the single source of truth.
  These are SELF-BUILT or LOCALLY-ADAPTED skills — do not replace them blindly:

    - datastar               self-built (own Datastar conventions)
    - go-web-init            self-built (personal Go+Datastar+Tailwind stack)
    - show-me                adapted from humanlayer/skills: upstream sets
                             disable-model-invocation:true; local copy enables
                             model invocation with a broader description

  Skills managed by the skills.sh CLI (`npx skills`) live OUTSIDE dotfiles, in
  the cross-agent global dir ~/.agents/skills/ (pi >= 1.5.x reads that
  natively — no symlinks needed):

    - impeccable                    (github.com/pbakaus/impeccable)
    - incremental-implementation    (github.com/addyosmani/agent-skills)
    - lavish                        (github.com/kunchenguid/lavish-axi)
    - systematic-debugging          (github.com/obra/superpowers)
    - test-driven-development       (github.com/obra/superpowers)
    - verification-before-completion (github.com/obra/superpowers)

  Install one skill from a multi-skill repo with the @ syntax:
    npx skills add obra/superpowers@test-driven-development -g -y
  Manage:
    npx skills list / update / remove
  History: web-design-engineer was deleted (superseded by impeccable), not
  archived. The 5 skills above were previously manual copies in dotfiles
  (verified upstream-identical before switching, 2025-11-12).
-->
