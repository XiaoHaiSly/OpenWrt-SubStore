include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Sub-Store (Subscription Manager)
LUCI_DEPENDS:=+node +unzip

PKG_NAME:=luci-app-substore
PKG_VERSION:=2026.07.29
PKG_RELEASE:=2
PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=xiaohai

SUBSTORE_BACKEND_TAG:=2.36.26
SUBSTORE_FRONTEND_TAG:=2.29.8

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-substore/install
	SUBSTORE_BACKEND_TAG="$(SUBSTORE_BACKEND_TAG)" \
	SUBSTORE_FRONTEND_TAG="$(SUBSTORE_FRONTEND_TAG)" \
	sh $(CURDIR)/scripts/package-install.sh $(1) $(CURDIR)
endef

define Package/luci-app-substore/conffiles
/etc/config/substore
endef

define Package/luci-app-substore/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
/usr/libexec/substore/postinstall.sh
exit 0
endef

$(eval $(call BuildPackage,luci-app-substore))
