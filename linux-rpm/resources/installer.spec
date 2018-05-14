%define _product_name
%define _product_version
# %define _product_install_directory
%define _product

Name:           %{_product}
Version:        
Release:        1
Summary:        %{_product}-%{_product_version}
License:        Apache license 2.0
URL:            https://www.wso2.com/

# Disable Automatic Dependencies
AutoReqProv: no
# Override RPM file name
%define _rpmfilename %%{ARCH}/%{_product}-%{_product_version}-runtime-linux-installer-x64-%{_product_version}.rpm
# Disable Jar repacking
%define __jar_repack %{nil}

%description
%{_product}-%{_product_version}

%pre
rm -f /usr/bin/%{_product}> /dev/null 2>&1

%prep
rm -rf %{_topdir}/BUILD/*
cp -r %{_topdir}/SOURCES/%{_product_name}/* %{_topdir}/BUILD/
%build
%install
rm -rf $RPM_BUILD_ROOT
install -d %{buildroot}%{_libdir}/%{_product}/%{_product_name}
cp -r bin bre lib src %{buildroot}%{_libdir}//%{_product}/%{_product_name}

%post
ln -sf %{_libdir}/%{_product}/%{_product_name}/bin/wso2server.sh /usr/bin/%{_product}
# echo 'export BALLERINA_HOME=' >> /etc/profile.d/wso2.sh
# chmod 0755 /etc/profile.d/wso2.sh

%postun
# sed -i.bak '\:SED_BALLERINA_HOME:d' /etc/profile.d/wso2.sh
if [ "$(readlink /usr/bin/%{_product})" = "%{_libdir}/%{_product}/%{_product_name}/bin/wso2server.sh" ]
then
  rm -f /usr/bin/%{_product}
fi

%clean
rm -rf %{_topdir}/BUILD/*
rm -rf %{buildroot}

%files
%{_libdir}/%{_product}/%{_product_name}
%doc COPYRIGHT LICENSE README