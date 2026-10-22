{ lib }:
let

  getDirectories_ =
    path_:
    (lib.mapAttrs (name_: unused_type_: path_ + "/${name_}") (
      lib.filterAttrs (unused_name_: type_: type_ == "directory") (builtins.readDir path_)
    ));

  resolvePath_ = relativePath_: path_: path_ + "/${relativePath_}";

  hasPath_ = relativePath_: path_: builtins.pathExists (resolvePath_ relativePath_ path_);

  hasEntries_ =
    relativePath_: path_:
    (builtins.any (
      child_: if hasPath_ relativePath_ child_ then true else hasEntries_ relativePath_ child_
    ) (builtins.attrValues (getDirectories_ path_)));

  mkLegacyPackages_ =
    overlayFile_: pkgs_: root_:
    (lib.mapAttrs
      (
        name_: child_:
        if !(builtins.hasAttr name_ pkgs_) then
          builtins.throw "packages.mkLegacyPackages: `${name_}` does not exist in the package set"
        else if lib.isDerivation pkgs_.${name_} then
          pkgs_.${name_}
        else if builtins.isAttrs pkgs_.${name_} then
          mkLegacyPackages_ overlayFile_ pkgs_.${name_} child_
        else
          builtins.throw "packages.mkLegacyPackages: `${name_}` is not a package namespace"
      )
      (
        lib.filterAttrs (
          name_: child_:
          hasEntries_ overlayFile_ child_
          || (hasPath_ overlayFile_ child_ && lib.isDerivation (pkgs_.${name_} or null))
        ) (getDirectories_ root_)
      )
    );

  mkScope_ =
    overlayFile_: pkgs_: root_:
    (lib.makeScope pkgs_.newScope (self_: mkLegacyPackages_ overlayFile_ self_ root_));

  isOverlayFactory_ =
    overlayFile_: root_:
    if hasPath_ overlayFile_ root_ then
      (builtins.functionArgs (import (resolvePath_ overlayFile_ root_))) ? descendantOverlay
    else
      false;

  loadOverlay_ =
    overlayFile_: root_:
    let
      overlay_ = import (resolvePath_ overlayFile_ root_);
    in
    if (builtins.functionArgs overlay_) ? descendantOverlay then
      overlay_ { descendantOverlay = mkOverlay_ overlayFile_ root_; }
    else
      overlay_;

  mkAttrsetOverlay_ =
    final_: previous_: overlay_:
    let

      scope_ = (
        lib.makeScope final_.newScope (
          self_:
          (lib.mergeAttrsList [
            previous_
            (overlay_ self_ previous_)
          ])
        )
      );

    in
    (lib.mergeAttrsList [
      previous_
      (overlay_ scope_ previous_)
    ]);

  mkNamespaceOverlay_ =
    overlayFile_: name_: root_:
    let

      overlay_ = mkOverlay_ overlayFile_ root_;

    in
    final_: prev_:
    (lib.setAttrByPath [ name_ ] (
      if builtins.hasAttr name_ prev_ then
        let

          previous_ = builtins.getAttr name_ prev_;

        in
        (
          if builtins.isAttrs previous_ then
            (
              if lib.isDerivation previous_ then
                builtins.throw "packages.mkOverlay: `${name_}` already exists and is a derivation"
              else
                (
                  if previous_ ? overrideScope then
                    previous_.overrideScope overlay_
                  else
                    mkAttrsetOverlay_ final_ previous_ overlay_
                )
            )
          else
            builtins.throw "packages.mkOverlay: `${name_}` already exists and is not an attribute set"
        )
      else
        (lib.makeScope final_.newScope (self_: overlay_ self_ { }))
    ));

  mkOverlay_ =
    overlayFile_: root_:
    let

      directories_ = getDirectories_ root_;

      localOverlays_ = (
        lib.mapAttrsToList (unused_name_: child_: loadOverlay_ overlayFile_ child_) (
          lib.filterAttrs (unused_name_: child_: hasPath_ overlayFile_ child_) directories_
        )
      );

      namespaceOverlays_ = (
        lib.mapAttrsToList (name_: child_: mkNamespaceOverlay_ overlayFile_ name_ child_) (
          lib.filterAttrs (
            unused_name_: child_:
            if isOverlayFactory_ overlayFile_ child_ then false else hasEntries_ overlayFile_ child_
          ) directories_
        )
      );

    in
    (lib.composeManyExtensions (
      builtins.concatLists [
        localOverlays_
        namespaceOverlays_
      ]
    ));

  mkOverlays_ =
    overlayFile_: root_:
    lib.mapAttrs
      (
        name_: child_:
        lib.composeManyExtensions (
          builtins.concatLists [
            (lib.optional (hasPath_ overlayFile_ child_) (loadOverlay_ overlayFile_ child_))
            (lib.optional (
              if isOverlayFactory_ overlayFile_ child_ then false else hasEntries_ overlayFile_ child_
            ) (mkNamespaceOverlay_ overlayFile_ name_ child_))
          ]
        )
      )
      (
        lib.filterAttrs (
          unused_name_: child_:
          builtins.any (x_: x_) [
            (hasPath_ overlayFile_ child_)
            (hasEntries_ overlayFile_ child_)
          ]
        ) (getDirectories_ root_)
      );

  mkModule_ = modulePath_: root_: {

    imports = (
      builtins.concatLists (
        lib.mapAttrsToList (
          unused_name_: child_:
          if hasPath_ modulePath_ child_ then
            [ (resolvePath_ modulePath_ child_) ]
          else
            (mkModule_ modulePath_ child_).imports
        ) (getDirectories_ root_)
      )
    );

  };

in
{

  mkLegacyPackages =
    {
      root,
      pkgs,
      overlayFile,
    }:
    (mkLegacyPackages_ overlayFile pkgs root);

  mkOverlays = { root, overlayFile }: (mkOverlays_ overlayFile root);

  mkNixosModule = { root, modulePath }: (mkModule_ modulePath root);

  mkHomeModule = { root, modulePath }: (mkModule_ modulePath root);

}
