/**
 * Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebar: SidebarsConfig = {
  iosSdkSidebar: [
    {
      type: 'doc',
      id: 'sdks/ios/overview',
    },
    {
      type: 'category',
      label: 'APIs',
      collapsed: false,
      items: [
        {
          type: 'doc',
          id: 'sdks/ios/apis/thunder-config',
          label: 'ThunderConfig',
        },
        {
          type: 'doc',
          id: 'sdks/ios/apis/thunder-client',
          label: 'ThunderClient',
        },
      ],
    },
    {
      type: 'category',
      label: 'SwiftUI Components',
      collapsed: false,
      items: [
        {
          type: 'doc',
          id: 'sdks/ios/components/overview',
          label: 'Overview',
        },
        {
          type: 'doc',
          id: 'sdks/ios/components/action-components',
          label: 'Action Components',
        },
        {
          type: 'doc',
          id: 'sdks/ios/components/control-components',
          label: 'Control Components',
        },
        {
          type: 'doc',
          id: 'sdks/ios/components/user-components',
          label: 'User Components',
        },
        {
          type: 'doc',
          id: 'sdks/ios/components/organization-components',
          label: 'Organization Components',
        },
      ],
    },
  ],
};

export default sidebar.iosSdkSidebar;
