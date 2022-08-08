import React, { useCallback, useContext, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import ACSCreateContext from '../ACSCreateContext';
import { selectCreateACS, selectCreateACSError, selectCreateACSStatus } from '../../ACSSelectors';
import { createACS } from '../../ACSActions';
import Loading from '../../../../components/Loading';

const ACSCreateFinish = () => {
  const { push } = useHistory();
  const {
    currentStep,
    setIsOpen,
    acsType,
    contentType,
    name,
    description,
    smartProxies,
    url,
    subpaths,
    verifySSL,
    authentication,
    sslCert,
    sslKey,
    username,
    password,
    caCert,
    productIds,
  } = useContext(ACSCreateContext);
  const dispatch = useDispatch();
  const response = useSelector(state => selectCreateACS(state));
  const status = useSelector(state => selectCreateACSStatus(state));
  const error = useSelector(state => selectCreateACSError(state));
  const [createACSDispatched, setCreateACSDispatched] = useState(false);
  const [saving, setSaving] = useState(true);

  const acsTypeParams = useCallback((params, type) => {
    let acsParams = params;
    if (type === 'custom') {
      acsParams = {
        base_url: url, verify_ssl: verifySSL, ssl_ca_cert_id: caCert, ...acsParams,
      };
      if (subpaths !== '') {
        acsParams = { subpaths: subpaths.split(','), ...acsParams };
      }
    }
    if (type === 'simplified') {
      acsParams = { product_ids: productIds, ...acsParams };
    }
    return acsParams;
  }, [caCert, productIds, subpaths, url, verifySSL]);

  useDeepCompareEffect(() => {
    if (currentStep === 8 && !createACSDispatched) {
      setCreateACSDispatched(true);
      let params = {
        name,
        description,
        smart_proxy_names: smartProxies,
        content_type: contentType,
        alternate_content_source_type: acsType,
      };
      params = acsTypeParams(params, acsType);
      if (authentication === 'content_credentials') {
        params = { ssl_client_cert_id: sslCert, ssl_client_key_id: sslKey, ...params };
      }
      if (authentication === 'manual') {
        params = { upstream_username: username, upstream_password: password, ...params };
      }
      dispatch(createACS(params));
    }
  }, [dispatch, createACSDispatched, setCreateACSDispatched,
    acsType, authentication, name, description, url, subpaths,
    smartProxies, contentType, verifySSL, caCert, sslCert, sslKey,
    username, password, currentStep, acsTypeParams]);

  useDeepCompareEffect(() => {
    const { id } = response;
    if (id && status === STATUS.RESOLVED && saving) {
      setSaving(false);
      push(`/labs/alternate_content_sources/${id}/details`);
      setIsOpen(false);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
      setIsOpen(false);
    }
  }, [response, status, error, push, saving, dispatch, setIsOpen]);

  return <Loading loadingText={__('Saving alternate content source...')} />;
};

export default ACSCreateFinish;