// Claude Code API Web Interface
class ApiManager {
    constructor() {
        this.baseUrl = 'http://localhost:8080/api';
        this.currentLanguage = localStorage.getItem('language') || 'en';
        this.translations = {
            en: {
                title: 'Claude Code API Configuration Manager',
                subtitle: 'Web Interface - Manage and Switch API Provider Configurations',
                currentStatus: '🔍 Current Configuration Status',
                clearConfig: 'Clear Configuration',
                refreshStatus: 'Refresh Status',
                modelManagement: '🔧 Model Configuration Management',
                searchPlaceholder: 'Search models...',
                addNewModel: '➕ Add New Model',
                addModelTitle: 'Add New Model Configuration',
                modelIdLabel: 'Model ID *',
                modelIdPlaceholder: 'e.g. claude3',
                displayNameLabel: 'Display Name *',
                displayNamePlaceholder: 'e.g. Claude 3',
                descriptionLabel: 'Description',
                descriptionPlaceholder: 'Model description',
                baseUrlLabel: 'API Base URL *',
                baseUrlPlaceholder: 'e.g. https://api.example.com/anthropic',
                apiKeyEnvLabel: 'API Key Environment Variable *',
                apiKeyEnvPlaceholder: 'e.g. CLAUDE_API_KEY',
                mainModelLabel: 'Main Model Name *',
                mainModelPlaceholder: 'e.g. claude-3-opus',
                fastModelLabel: 'Fast Model Name',
                fastModelPlaceholder: 'e.g. claude-3-haiku (leave empty to use main model)',
                save: 'Save',
                cancel: 'Cancel',
                edit: 'Edit',
                switchToModel: 'Switch to this model',
                delete: 'Delete',
                languageSwitch: 'CN',
                statusBaseUrl: 'Base URL:',
                statusMainModel: 'Main Model:',
                statusFastModel: 'Fast Model:',
                statusCurrentProvider: 'Current Provider:',
                noConfigured: '🚫 No API provider currently configured',
                pleaseSelect: 'Please select a model to configure',
                description: 'Description:',
                api: 'API:',
                environmentVar: 'Environment Variable:',
                models: 'Models:',
                editModelTitle: 'Edit Model Configuration',
                deleteConfirm: 'Are you sure you want to delete model "{0}" ({1})? This operation cannot be undone.',
                clearConfirm: 'Are you sure you want to clear the current API configuration?',
                // API密钥管理
                apiKeyManagement: '🔑 API Key Management',
                apiKeyStatus: 'API Key Status',
                setApiKey: 'Set API Key',
                apiKeyPlaceholder: 'Enter your API key...',
                apiKeySet: 'Set',
                apiKeyConfigured: 'Configured',
                apiKeyNotSet: 'Not Set',
                apiKeyUpdated: 'API key updated successfully',
                apiKeyInvalid: 'Please enter a valid API key',
                // 模型测试
                modelTesting: '🧪 Model Testing',
                testPrompt: 'Test current model configuration',
                promptPlaceholder: 'Enter your test prompt here...',
                testModel: 'Test Model',
                testResult: 'Test Result',
                testSuccess: 'Model test completed successfully',
                testFailed: 'Model test failed',
                noModelConfigured: 'Please configure a model first',
                promptRequired: 'Please enter a test prompt',
                loading: 'Loading...',
                // API密钥新增
                addApiKey: 'Add API Key',
                addNewApiKey: '➕ Add New API Key',
                envVarName: 'Environment Variable Name',
                envVarPlaceholder: 'e.g. DEEPSEEK_API_KEY',
                apiKeyValue: 'API Key Value',
                apiKeyValuePlaceholder: 'Enter your API key...',
                addApiKeyTitle: 'Add New API Key',
                envVarRequired: 'Please enter environment variable name',
                apiKeyRequired: 'Please enter API key value',
                apiKeyAdded: 'API key added successfully',
                apiKeyDelete: 'Delete',
                apiKeyDeleted: 'API key deleted successfully',
                apiKeyDeleteConfirm: 'Are you sure you want to delete API key "{0}"? This will remove it from your system environment variables.'
            },
            zh: {
                title: 'Claude Code API 配置管理器',
                subtitle: 'Web界面 - 管理和切换API提供商配置',
                currentStatus: '🔍 当前配置状态',
                clearConfig: '清除配置',
                refreshStatus: '刷新状态',
                modelManagement: '🔧 模型配置管理',
                searchPlaceholder: '搜索模型...',
                addNewModel: '➕ 添加新模型',
                addModelTitle: '添加新模型配置',
                modelIdLabel: '模型ID *',
                modelIdPlaceholder: '例如：claude3',
                displayNameLabel: '显示名称 *',
                displayNamePlaceholder: '例如：Claude 3',
                descriptionLabel: '描述',
                descriptionPlaceholder: '模型描述',
                baseUrlLabel: 'API基础URL *',
                baseUrlPlaceholder: '例如：https://api.example.com/anthropic',
                apiKeyEnvLabel: 'API密钥环境变量 *',
                apiKeyEnvPlaceholder: '例如：CLAUDE_API_KEY',
                mainModelLabel: '主模型名称 *',
                mainModelPlaceholder: '例如：claude-3-opus',
                fastModelLabel: '快速模型名称',
                fastModelPlaceholder: '例如：claude-3-haiku（留空使用主模型）',
                save: '保存',
                cancel: '取消',
                edit: '编辑',
                switchToModel: '切换到此模型',
                delete: '删除',
                languageSwitch: 'EN',
                statusBaseUrl: '基础URL：',
                statusMainModel: '主模型：',
                statusFastModel: '快速模型：',
                statusCurrentProvider: '当前提供商：',
                noConfigured: '🚫 当前未配置API提供商',
                pleaseSelect: '请选择模型进行配置',
                description: '描述：',
                api: 'API：',
                environmentVar: '环境变量：',
                models: '模型：',
                editModelTitle: '编辑模型配置',
                deleteConfirm: '确定要删除模型"{0}"（{1}）吗？此操作无法撤销。',
                clearConfirm: '确定要清除当前API配置吗？',
                // API密钥管理
                apiKeyManagement: '🔑 API密钥管理',
                apiKeyStatus: 'API密钥状态',
                setApiKey: '设置API密钥',
                apiKeyPlaceholder: '输入您的API密钥...',
                apiKeySet: '设置',
                apiKeyConfigured: '已配置',
                apiKeyNotSet: '未设置',
                apiKeyUpdated: 'API密钥更新成功',
                apiKeyInvalid: '请输入有效的API密钥',
                // 模型测试
                modelTesting: '🧪 模型测试',
                testPrompt: '测试当前模型配置',
                promptPlaceholder: '在此输入您的测试提示词...',
                testModel: '测试模型',
                testResult: '测试结果',
                testSuccess: '模型测试完成',
                testFailed: '模型测试失败',
                noModelConfigured: '请先配置一个模型',
                promptRequired: '请输入测试提示词',
                loading: '加载中...',
                // API密钥新增
                addApiKey: '添加API密钥',
                addNewApiKey: '➕ 添加新API密钥',
                envVarName: '环境变量名称',
                envVarPlaceholder: '例如：DEEPSEEK_API_KEY',
                apiKeyValue: 'API密钥值',
                apiKeyValuePlaceholder: '输入您的API密钥...',
                addApiKeyTitle: '添加新API密钥',
                envVarRequired: '请输入环境变量名称',
                apiKeyRequired: '请输入API密钥值',
                apiKeyAdded: 'API密钥添加成功',
                apiKeyDelete: '删除',
                apiKeyDeleted: 'API密钥删除成功',
                apiKeyDeleteConfirm: '确定要删除API密钥"{0}"吗？这将从您的系统环境变量中移除它。'
            }
        };
        this.editingModelId = null;
        this.init();
    }

    async init() {
        this.updateLanguage();
        await this.loadCurrentStatus();
        await this.loadModels();
        await this.loadApiKeys();
    }

    // 切换语言
    async toggleLanguage() {
        this.currentLanguage = this.currentLanguage === 'en' ? 'zh' : 'en';
        localStorage.setItem('language', this.currentLanguage);
        this.updateLanguage();
        
        // 重新渲染动态内容以应用新语言
        await this.refreshDynamicContent();
    }

    // 更新页面语言
    updateLanguage() {
        const elements = document.querySelectorAll('[data-lang-key]');
        elements.forEach(element => {
            const key = element.getAttribute('data-lang-key');
            if (this.translations[this.currentLanguage][key]) {
                if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
                    element.placeholder = this.translations[this.currentLanguage][key];
                } else {
                    element.textContent = this.translations[this.currentLanguage][key];
                }
            }
        });
    }

    // 刷新动态内容（用于语言切换）
    async refreshDynamicContent() {
        try {
            // 重新加载并显示当前状态
            const status = await this.apiCall('/status');
            this.displayCurrentStatus(status);
            
            // 重新加载并显示模型列表
            const models = await this.apiCall('/models');
            this.displayModels(models);
            
            // 重新加载API密钥状态
            await this.loadApiKeys();
        } catch (error) {
            console.error('Failed to refresh dynamic content:', error);
        }
    }

    // 显示消息
    showMessage(message, type = 'success') {
        const messageEl = document.getElementById('message');
        const overlayEl = document.getElementById('message-overlay');
        
        messageEl.textContent = message;
        messageEl.className = `message ${type}`;
        
        // 显示遮罩和消息
        overlayEl.classList.add('show');
        messageEl.style.display = 'block';
        
        // 自动隐藏消息（除了错误信息）
        const hideTimeout = type === 'error' ? 8000 : 5000;
        
        setTimeout(() => {
            if (messageEl.style.display !== 'none') {
                hideMessage();
            }
        }, hideTimeout);
        
        // 点击遮罩层也可以关闭消息
        const hideMessage = () => {
            messageEl.style.display = 'none';
            overlayEl.classList.remove('show');
            overlayEl.removeEventListener('click', hideMessage);
            document.removeEventListener('keydown', escapeHandler);
        };
        
        // ESC键关闭消息
        const escapeHandler = (e) => {
            if (e.key === 'Escape') {
                hideMessage();
            }
        };
        
        overlayEl.addEventListener('click', hideMessage);
        document.addEventListener('keydown', escapeHandler);
    }

    // 显示信息类消息
    showInfo(message) {
        this.showMessage(message, 'info');
    }

    // 显示警告消息
    showWarning(message) {
        this.showMessage(message, 'warning');
    }

    // 显示错误消息
    showError(message) {
        this.showMessage(message, 'error');
    }

    // 设置按钮加载状态（优化版本，避免与全局加载重复）
    setButtonLoading(button, loading = true) {
        if (loading) {
            button.disabled = true;
            button.classList.add('loading');
            button.setAttribute('data-original-text', button.textContent);
            // 如果全局加载正在显示，则不显示按钮加载动画
            const globalLoading = document.getElementById('page-loading');
            if (globalLoading && globalLoading.classList.contains('show')) {
                button.classList.remove('loading');
            }
        } else {
            button.disabled = false;
            button.classList.remove('loading');
            const originalText = button.getAttribute('data-original-text');
            if (originalText) {
                button.textContent = originalText;
                button.removeAttribute('data-original-text');
            }
        }
    }

    // 设置全局加载状态
    setGlobalLoading(loading = true) {
        const buttons = document.querySelectorAll('.btn');
        buttons.forEach(button => {
            if (loading) {
                button.disabled = true;
            } else {
                button.disabled = false;
            }
        });
        
        // 显示/隐藏居中加载状态
        const loadingElement = document.getElementById('page-loading');
        if (loadingElement) {
            if (loading) {
                loadingElement.classList.add('show');
            } else {
                loadingElement.classList.remove('show');
            }
        }
        
        if (loading) {
            document.body.classList.add('is-loading');
        } else {
            document.body.classList.remove('is-loading');
        }
    }

    // API调用封装（优化版本，根据是否有特定按钮来决定加载状态显示方式）
    async apiCall(endpoint, options = {}, targetButton = null) {
        // 如果有特定按钮，只显示按钮加载状态，否则显示全局加载状态
        if (targetButton) {
            this.setButtonLoading(targetButton, true);
        } else {
            this.setGlobalLoading(true);
        }
        
        try {
            console.log(`API Call: ${options.method || 'GET'} ${endpoint}`, options); // 调试信息
            
            const response = await fetch(`${this.baseUrl}${endpoint}`, {
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                },
                ...options
            });

            console.log(`API Response Status: ${response.status}`, response); // 调试信息

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const contentType = response.headers.get('content-type');
            let result;
            if (contentType && contentType.includes('application/json')) {
                result = await response.json();
            } else {
                result = await response.text();
            }
            
            console.log('API Response Data:', result); // 调试信息
            return result;
        } catch (error) {
            console.error('API Error:', error);
            this.showError(`API 调用失败: ${error.message}`);
            throw error;
        } finally {
            if (targetButton) {
                this.setButtonLoading(targetButton, false);
            } else {
                this.setGlobalLoading(false);
            }
        }
    }

    // 加载当前状态
    async loadCurrentStatus() {
        try {
            const status = await this.apiCall('/status');
            this.displayCurrentStatus(status);
        } catch (error) {
            document.getElementById('current-status').innerHTML = 
                '<div class="loading" style="color: #e74c3c;">无法加载当前状态 - 请确保后端服务正在运行</div>';
        }
    }

    // 加载模型列表
    async loadModels() {
        try {
            const models = await this.apiCall('/models');
            this.displayModels(models);
        } catch (error) {
            document.getElementById('models-container').innerHTML = 
                '<div class="loading" style="color: #e74c3c;">无法加载模型配置 - 请确保后端服务正在运行</div>';
        }
    }

    // 加载API密钥状态
    async loadApiKeys() {
        try {
            const keys = await this.apiCall('/keys');
            this.displayApiKeys(keys);
        } catch (error) {
            document.getElementById('api-keys-container').innerHTML = 
                '<div class="loading" style="color: #e74c3c;">无法加载API密钥状态 - 请确保后端服务正在运行</div>';
        }
    }

    // 显示当前状态
    displayCurrentStatus(status) {
        const container = document.getElementById('current-status');
        const t = this.translations[this.currentLanguage];
        
        if (status.configured) {
            container.innerHTML = `
                <div class="status-item">
                    <span class="status-label">${t.statusBaseUrl}</span>
                    <span class="status-value">${status.baseUrl || 'Not set'}</span>
                </div>
                <div class="status-item">
                    <span class="status-label">${t.statusMainModel}</span>
                    <span class="status-value">${status.model || 'Not set'}</span>
                </div>
                <div class="status-item">
                    <span class="status-label">${t.statusFastModel}</span>
                    <span class="status-value">${status.fastModel || 'Not set'}</span>
                </div>
                <div class="status-item">
                    <span class="status-label">${t.statusCurrentProvider}</span>
                    <span class="status-value" style="font-weight: bold; color: #27ae60;">${status.provider || 'Unknown'}</span>
                </div>
            `;
        } else {
            container.innerHTML = `
                <div style="text-align: center; color: #7f8c8d;">
                    <p>${t.noConfigured}</p>
                    <p>${t.pleaseSelect}</p>
                </div>
            `;
        }
    }
    displayModels(models) {
        const container = document.getElementById('models-container');
        const t = this.translations[this.currentLanguage];
        
        if (!models || models.length === 0) {
            container.innerHTML = '<div class="loading">No model configurations found</div>';
            return;
        }

        container.innerHTML = models.map(model => `
            <div class="model-card" data-model-id="${model.id}">
                <h3>${model.name}</h3>
                <div class="model-info">
                    <span><strong>${t.description}</strong> ${model.description || 'No description'}</span>
                    <span><strong>${t.api}</strong> ${model.base_url}</span>
                    <span><strong>${t.environmentVar}</strong> ${model.api_key_env}</span>
                    <span><strong>${t.models}</strong> ${model.model} / ${model.fast_model}</span>
                </div>
                <div class="button-group">
                    <button class="btn btn-primary" onclick="apiManager.switchToModel('${model.id}', this)">
                        ${t.switchToModel}
                    </button>
                    <button class="btn btn-warning" onclick="apiManager.editModel('${model.id}')">
                        ${t.edit}
                    </button>
                    <button class="btn btn-danger" onclick="apiManager.deleteModel('${model.id}', '${model.name}', this)">
                        ${t.delete}
                    </button>
                </div>
                <div id="edit-form-${model.id}" class="edit-form">
                    <h4>${t.editModelTitle}</h4>
                    <form onsubmit="apiManager.updateModel(event, '${model.id}')">
                        <div class="form-group">
                            <label>${t.displayNameLabel}</label>
                            <input type="text" id="edit-name-${model.id}" value="${model.name}" required>
                        </div>
                        <div class="form-group">
                            <label>${t.descriptionLabel}</label>
                            <textarea id="edit-desc-${model.id}">${model.description || ''}</textarea>
                        </div>
                        <div class="form-group">
                            <label>${t.baseUrlLabel}</label>
                            <input type="url" id="edit-url-${model.id}" value="${model.base_url}" required>
                        </div>
                        <div class="form-group">
                            <label>${t.apiKeyEnvLabel}</label>
                            <input type="text" id="edit-env-${model.id}" value="${model.api_key_env}" required>
                        </div>
                        <div class="form-group">
                            <label>${t.mainModelLabel}</label>
                            <input type="text" id="edit-main-${model.id}" value="${model.model}" required>
                        </div>
                        <div class="form-group">
                            <label>${t.fastModelLabel}</label>
                            <input type="text" id="edit-fast-${model.id}" value="${model.fast_model}">
                        </div>
                        <div class="button-group">
                            <button type="submit" class="btn btn-success">${t.save}</button>
                            <button type="button" class="btn btn-danger" onclick="apiManager.cancelEdit('${model.id}')">${t.cancel}</button>
                        </div>
                    </form>
                </div>
            </div>
        `).join('');
    }

    // 切换到指定模型
    async switchToModel(modelId, buttonElement = null) {
        try {
            const result = await this.apiCall('/switch', {
                method: 'POST',
                body: JSON.stringify({ modelId })
            }, buttonElement);
            
            this.showMessage(`成功切换到模型: ${modelId}`);
            await this.loadCurrentStatus();
        } catch (error) {
            this.showError(`切换模型失败: ${error.message}`);
        }
    }

    // 编辑模型
    editModel(modelId) {
        // 隐藏其他编辑表单
        document.querySelectorAll('.edit-form').forEach(form => {
            form.style.display = 'none';
        });
        
        // 显示当前编辑表单
        const editForm = document.getElementById(`edit-form-${modelId}`);
        editForm.style.display = 'block';
        this.editingModelId = modelId;
    }

    // 取消编辑
    cancelEdit(modelId) {
        const editForm = document.getElementById(`edit-form-${modelId}`);
        editForm.style.display = 'none';
        this.editingModelId = null;
    }

    // 更新模型
    async updateModel(event, modelId) {
        event.preventDefault();
        
        const formData = {
            id: modelId,
            name: document.getElementById(`edit-name-${modelId}`).value,
            description: document.getElementById(`edit-desc-${modelId}`).value,
            base_url: document.getElementById(`edit-url-${modelId}`).value,
            api_key_env: document.getElementById(`edit-env-${modelId}`).value,
            model: document.getElementById(`edit-main-${modelId}`).value,
            fast_model: document.getElementById(`edit-fast-${modelId}`).value || document.getElementById(`edit-main-${modelId}`).value
        };

        // 验证必填字段
        if (!formData.name || !formData.base_url || !formData.api_key_env || !formData.model) {
            this.showError('Please fill in all required fields');
            return;
        }

        try {
            await this.apiCall(`/models/${modelId}`, {
                method: 'PUT',
                body: JSON.stringify(formData)
            });
            
            this.showMessage(`Successfully updated model: ${formData.name}`);
            this.cancelEdit(modelId);
            await this.loadModels();
        } catch (error) {
            this.showError(`Failed to update model: ${error.message}`);
        }
    }
    async switchToModel(modelId) {
        try {
            const result = await this.apiCall('/switch', {
                method: 'POST',
                body: JSON.stringify({ modelId })
            });
            
            this.showMessage(`Successfully switched to model: ${modelId}`);
            await this.loadCurrentStatus();
        } catch (error) {
            this.showError(`Failed to switch model: ${error.message}`);
        }
    }

    // 删除模型
    async deleteModel(modelId, modelName, buttonElement = null) {
        const t = this.translations[this.currentLanguage];
        const confirmMsg = t.deleteConfirm.replace('{0}', modelName).replace('{1}', modelId);
        
        if (!confirm(confirmMsg)) {
            return;
        }

        try {
            await this.apiCall(`/models/${modelId}`, {
                method: 'DELETE'
            }, buttonElement);
            
            this.showMessage(`成功删除模型: ${modelName}`);
            await this.loadModels();
        } catch (error) {
            this.showError(`删除模型失败: ${error.message}`);
        }
    }

    // 添加新模型
    async addModel(event) {
        event.preventDefault();
        
        const submitButton = event.target.querySelector('button[type="submit"]');
        
        const formData = {
            id: document.getElementById('model-id').value,
            name: document.getElementById('model-name').value,
            description: document.getElementById('model-description').value,
            base_url: document.getElementById('model-base-url').value,
            api_key_env: document.getElementById('model-api-key-env').value,
            model: document.getElementById('model-main').value,
            fast_model: document.getElementById('model-fast').value || document.getElementById('model-main').value
        };

        // 验证必填字段
        if (!formData.id || !formData.name || !formData.base_url || !formData.api_key_env || !formData.model) {
            this.showError('请填写所有必填字段');
            return;
        }

        // 验证ID格式
        if (!/^[a-zA-Z0-9_-]+$/.test(formData.id)) {
            this.showError('模型ID只能包含字母、数字、下划线和连字符');
            return;
        }

        try {
            await this.apiCall('/models', {
                method: 'POST',
                body: JSON.stringify(formData)
            }, submitButton);
            
            this.showMessage(`成功添加模型: ${formData.name}`);
            this.hideAddForm();
            this.clearAddForm();
            await this.loadModels();
        } catch (error) {
            this.showError(`添加模型失败: ${error.message}`);
        }
    }

    // 清空配置
    async clearConfiguration() {
        const t = this.translations[this.currentLanguage];
        
        if (!confirm(t.clearConfirm)) {
            return;
        }

        try {
            this.showInfo('正在清空配置...');
            
            // 使用静默方式调用API，避免显示加载状态
            await fetch(`${this.baseUrl}/clear`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            this.showMessage('配置已清空');
            
            // 静默刷新状态
            try {
                const status = await fetch(`${this.baseUrl}/status`).then(r => r.json());
                this.displayCurrentStatus(status);
            } catch (error) {
                console.error('刷新状态失败:', error);
            }
        } catch (error) {
            this.showError(`清空配置失败: ${error.message}`);
        }
    }

    // 刷新状态
    async refreshStatus() {
        try {
            this.showInfo('正在刷新状态...');
            
            // 静默刷新所有状态（不显示加载状态）
            try {
                // 并行加载所有数据
                const [status, models, keys] = await Promise.all([
                    fetch(`${this.baseUrl}/status`).then(r => r.json()),
                    fetch(`${this.baseUrl}/models`).then(r => r.json()),
                    fetch(`${this.baseUrl}/keys`).then(r => r.json())
                ]);
                
                // 更新显示
                this.displayCurrentStatus(status);
                this.displayModels(models);
                this.displayApiKeys(keys);
            } catch (error) {
                console.error('刷新数据失败:', error);
                // 如果静默刷新失败，则回退到原始方式
                await this.loadCurrentStatus();
                await this.loadModels();
                await this.loadApiKeys();
            }
            
            this.showMessage('状态已刷新');
        } catch (error) {
            this.showError(`刷新状态失败: ${error.message}`);
        }
    }

    // 显示添加表单
    showAddForm() {
        document.getElementById('add-form').style.display = 'block';
        document.getElementById('model-id').focus();
    }

    // 隐藏添加表单
    hideAddForm() {
        document.getElementById('add-form').style.display = 'none';
    }

    // 清空添加表单
    clearAddForm() {
        document.getElementById('model-id').value = '';
        document.getElementById('model-name').value = '';
        document.getElementById('model-description').value = '';
        document.getElementById('model-base-url').value = '';
        document.getElementById('model-api-key-env').value = '';
        document.getElementById('model-main').value = '';
        document.getElementById('model-fast').value = '';
    }

    // 模型搜索过滤
    filterModels() {
        const searchTerm = document.getElementById('search-box').value.toLowerCase();
        const modelCards = document.querySelectorAll('.model-card');
        
        modelCards.forEach(card => {
            const modelId = card.dataset.modelId.toLowerCase();
            const modelName = card.querySelector('h3').textContent.toLowerCase();
            const modelDesc = card.querySelector('.model-info').textContent.toLowerCase();
            
            if (modelId.includes(searchTerm) || 
                modelName.includes(searchTerm) || 
                modelDesc.includes(searchTerm)) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }

    // 加载API密钥状态
    async loadApiKeys() {
        try {
            const keys = await this.apiCall('/keys');
            this.displayApiKeys(keys);
        } catch (error) {
            document.getElementById('api-keys-container').innerHTML = 
                '<div class="loading" style="color: #e74c3c;">无法加载API密钥状态 - 请确保后端服务正在运行</div>';
        }
    }

    // 显示API密钥状态
    displayApiKeys(keys) {
        const container = document.getElementById('api-keys-container');
        const t = this.translations[this.currentLanguage];
        
        console.log('显示API密钥状态:', keys); // 调试信息
        
        if (!keys || Object.keys(keys).length === 0) {
            container.innerHTML = '<div class="loading">没有找到API密钥配置</div>';
            return;
        }

        // 按照isFromConfig分组，配置中的先显示，然后是自定义的
        const sortedKeys = Object.entries(keys).sort(([, a], [, b]) => {
            if (a.isFromConfig && !b.isFromConfig) return -1;
            if (!a.isFromConfig && b.isFromConfig) return 1;
            return a.envVar.localeCompare(b.envVar);
        });

        container.innerHTML = sortedKeys.map(([envVar, keyInfo]) => {
            const statusClass = keyInfo.hasKey ? 'configured' : 'not-configured';
            const statusText = keyInfo.hasKey ? t.apiKeyConfigured : t.apiKeyNotSet;
            const sourceText = keyInfo.isFromConfig ? '模型配置' : '自定义';
            
            return `
                <div class="api-key-card">
                    <div class="api-key-header">
                        <div>
                            <h4>${keyInfo.modelName} (${keyInfo.modelId})</h4>
                            <small style="color: #6c757d;">环境变量: ${envVar} | ${sourceText}</small>
                        </div>
                        <div class="api-key-status">
                            <span class="status-indicator ${statusClass}"></span>
                            <span>${statusText}</span>
                        </div>
                    </div>
                    ${keyInfo.hasKey ? `<div class="api-key-preview">API Key: ${keyInfo.keyPreview}</div>` : ''}
                    <div class="api-key-input-group">
                        <input type="password" 
                               class="api-key-input" 
                               id="key-input-${envVar}" 
                               placeholder="${t.apiKeyPlaceholder}" 
                               value="">
                        <div class="api-key-button-group">
                            <button class="btn btn-primary" 
                                    onclick="apiManager.setApiKey('${envVar}', this)">
                                ${t.apiKeySet}
                            </button>
                            ${!keyInfo.isFromConfig ? `
                                <button class="btn btn-danger" 
                                        onclick="apiManager.deleteApiKey('${envVar}', '${keyInfo.modelName}', this)"
                                        title="删除该API密钥">
                                    ${t.apiKeyDelete}
                                </button>
                            ` : ''}
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    }

    // 设置API密钥
    async setApiKey(envVar, buttonElement) {
        const input = document.getElementById(`key-input-${envVar}`);
        const apiKey = input.value.trim();
        
        if (!apiKey) {
            this.showError(this.translations[this.currentLanguage].apiKeyInvalid);
            return;
        }
        
        try {
            await this.apiCall('/keys', {
                method: 'POST',
                body: JSON.stringify({ 
                    envVar: envVar, 
                    apiKey: apiKey 
                })
            }, buttonElement);
            
            this.showMessage(this.translations[this.currentLanguage].apiKeyUpdated);
            input.value = ''; // 清空输入框
            
            // 静默刷新API密钥状态（不显示加载状态）
            try {
                const keys = await fetch(`${this.baseUrl}/keys`).then(r => r.json());
                this.displayApiKeys(keys);
            } catch (error) {
                console.error('刷新API密钥状态失败:', error);
            }
        } catch (error) {
            this.showError(`设置API密钥失败: ${error.message}`);
        }
    }

    // 删除API密钥
    async deleteApiKey(envVar, keyName, buttonElement) {
        const t = this.translations[this.currentLanguage];
        const confirmMsg = t.apiKeyDeleteConfirm.replace('{0}', keyName);
        
        if (!confirm(confirmMsg)) {
            return;
        }

        try {
            // 使用apiCall方法显示加载状态
            const result = await this.apiCall(`/keys/${encodeURIComponent(envVar)}`, {
                method: 'DELETE'
            }, buttonElement);
            
            if (result.success) {
                this.showMessage(t.apiKeyDeleted);
                
                // 静默刷新API密钥状态（不显示加载状态）
                try {
                    const keys = await fetch(`${this.baseUrl}/keys`).then(r => r.json());
                    this.displayApiKeys(keys);
                } catch (error) {
                    console.error('刷新API密钥状态失败:', error);
                }
            } else {
                this.showError(`删除API密钥失败: ${result.message || '未知错误'}`);
            }
        } catch (error) {
            this.showError(`删除API密钥失败: ${error.message}`);
        }
    }

    // 测试当前模型
    async testCurrentModel() {
        const promptInput = document.getElementById('test-prompt');
        const prompt = promptInput.value.trim();
        const t = this.translations[this.currentLanguage];
        
        if (!prompt) {
            this.showError(t.promptRequired);
            return;
        }

        const resultSection = document.getElementById('test-result-section');
        const resultDiv = document.getElementById('test-result');
        
        // 显示结果区域
        resultSection.style.display = 'block';
        resultDiv.className = 'test-result loading';
        resultDiv.textContent = '正在测试模型，请稍候...';
        
        try {
            this.showInfo('正在测试模型...');
            
            // 使用静默方式调用API，避免显示加载状态
            const response = await fetch(`${this.baseUrl}/test`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ prompt: prompt })
            });
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const result = await response.json();
            
            if (result.success) {
                resultDiv.className = 'test-result success';
                resultDiv.innerHTML = `
                    <div style="margin-bottom: 10px; color: #28a745; font-weight: bold;">
                        ✓ ${t.testSuccess}
                    </div>
                    <div style="margin-bottom: 5px; font-size: 0.9em; color: #6c757d;">
                        模型: ${result.model} | API: ${result.baseUrl}
                    </div>
                    <div style="padding-top: 10px; border-top: 1px solid #dee2e6;">
                        ${result.response}
                    </div>
                `;
                this.showMessage(t.testSuccess);
            } else {
                throw new Error(result.error || '未知错误');
            }
        } catch (error) {
            resultDiv.className = 'test-result error';
            resultDiv.innerHTML = `
                <div style="margin-bottom: 10px; font-weight: bold;">
                    ✕ ${t.testFailed}
                </div>
                <div>${error.message}</div>
            `;
            this.showError(`${t.testFailed}: ${error.message}`);
        }
    }

    // 显示添加API密钥表单
    showAddApiKeyForm() {
        document.getElementById('add-api-key-form').style.display = 'block';
        document.getElementById('api-key-env-var').focus();
    }

    // 隐藏添加API密钥表单
    hideAddApiKeyForm() {
        document.getElementById('add-api-key-form').style.display = 'none';
        this.clearAddApiKeyForm();
    }

    // 清空添加API密钥表单
    clearAddApiKeyForm() {
        document.getElementById('api-key-env-var').value = '';
        document.getElementById('api-key-value').value = '';
    }

    // 添加新API密钥
    async addNewApiKey(event) {
        event.preventDefault();
        
        console.log('addNewApiKey called'); // 调试信息
        
        const submitButton = event.target.querySelector('button[type="submit"]');
        const envVar = document.getElementById('api-key-env-var').value.trim();
        const apiKey = document.getElementById('api-key-value').value.trim();
        const t = this.translations[this.currentLanguage];
        
        console.log('Form data:', { envVar, apiKey: apiKey ? 'PROVIDED' : 'EMPTY' }); // 调试信息
        
        if (!envVar) {
            console.log('Missing envVar'); // 调试信息
            this.showError(t.envVarRequired);
            return;
        }
        
        if (!apiKey) {
            console.log('Missing apiKey'); // 调试信息
            this.showError(t.apiKeyRequired);
            return;
        }

        try {
            console.log('Sending API request...'); // 调试信息
            
            const result = await this.apiCall('/keys', {
                method: 'POST',
                body: JSON.stringify({ 
                    envVar: envVar, 
                    apiKey: apiKey 
                })
            }, submitButton);
            
            console.log('API response:', result); // 调试信息
            
            if (result.success) {
                this.showMessage(t.apiKeyAdded);
                this.hideAddApiKeyForm();
                
                // 静默刷新API密钥状态（不显示加载状态）
                console.log('刷新API密钥状态...'); // 调试信息
                try {
                    const keys = await fetch(`${this.baseUrl}/keys`).then(r => r.json());
                    this.displayApiKeys(keys);
                } catch (error) {
                    console.error('刷新API密钥状态失败:', error);
                }
                console.log('API密钥状态刷新完成'); // 调试信息
            } else {
                this.showError(`添加API密钥失败: ${result.message || '未知错误'}`);
            }
        } catch (error) {
            console.error('API error:', error); // 调试信息
            this.showError(`添加API密钥失败: ${error.message}`);
        }
    }
}

// 全局函数
let apiManager;

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', () => {
    apiManager = new ApiManager();
});

// 全局函数供HTML调用
function showAddForm() {
    apiManager.showAddForm();
}

function hideAddForm() {
    apiManager.hideAddForm();
}

function addModel(event) {
    return apiManager.addModel(event);
}

function clearConfiguration() {
    return apiManager.clearConfiguration();
}

function refreshStatus() {
    return apiManager.refreshStatus();
}

function filterModels() {
    return apiManager.filterModels();
}

function toggleLanguage() {
    return apiManager.toggleLanguage();
}

function testCurrentModel() {
    return apiManager.testCurrentModel();
}

function showAddApiKeyForm() {
    return apiManager.showAddApiKeyForm();
}

function hideAddApiKeyForm() {
    return apiManager.hideAddApiKeyForm();
}

function addNewApiKey(event) {
    return apiManager.addNewApiKey(event);
}

function deleteApiKey(envVar, keyName, buttonElement) {
    return apiManager.deleteApiKey(envVar, keyName, buttonElement);
}