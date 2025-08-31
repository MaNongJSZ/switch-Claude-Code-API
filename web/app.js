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
                clearConfirm: 'Are you sure you want to clear the current API configuration?'
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
                clearConfirm: '确定要清除当前API配置吗？'
            }
        };
        this.editingModelId = null;
        this.init();
    }

    async init() {
        this.updateLanguage();
        await this.loadCurrentStatus();
        await this.loadModels();
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
        } catch (error) {
            console.error('Failed to refresh dynamic content:', error);
        }
    }

    // 显示消息
    showMessage(message, type = 'success') {
        const messageEl = document.getElementById('message');
        messageEl.textContent = message;
        messageEl.className = `message ${type}`;
        messageEl.style.display = 'block';
        
        setTimeout(() => {
            messageEl.style.display = 'none';
        }, 5000);
    }

    // 显示错误
    showError(message) {
        this.showMessage(message, 'error');
    }

    // API调用封装
    async apiCall(endpoint, options = {}) {
        try {
            const response = await fetch(`${this.baseUrl}${endpoint}`, {
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                },
                ...options
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const contentType = response.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                return await response.json();
            } else {
                return await response.text();
            }
        } catch (error) {
            console.error('API Error:', error);
            this.showError(`API call failed: ${error.message}`);
            throw error;
        }
    }

    // 加载当前状态
    async loadCurrentStatus() {
        try {
            const status = await this.apiCall('/status');
            this.displayCurrentStatus(status);
        } catch (error) {
            document.getElementById('current-status').innerHTML = 
                '<div class="loading" style="color: #e74c3c;">Unable to load current status - Please ensure backend service is running</div>';
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

    // 加载模型列表
    async loadModels() {
        try {
            const models = await this.apiCall('/models');
            this.displayModels(models);
        } catch (error) {
            document.getElementById('models-container').innerHTML = 
                '<div class="loading" style="color: #e74c3c;">Unable to load model configurations - Please ensure backend service is running</div>';
        }
    }

    // 显示模型列表
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
                    <button class="btn btn-primary" onclick="apiManager.switchToModel('${model.id}')">
                        ${t.switchToModel}
                    </button>
                    <button class="btn btn-warning" onclick="apiManager.editModel('${model.id}')">
                        ${t.edit}
                    </button>
                    <button class="btn btn-danger" onclick="apiManager.deleteModel('${model.id}', '${model.name}')">
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
    async deleteModel(modelId, modelName) {
        const t = this.translations[this.currentLanguage];
        const confirmMsg = t.deleteConfirm.replace('{0}', modelName).replace('{1}', modelId);
        
        if (!confirm(confirmMsg)) {
            return;
        }

        try {
            await this.apiCall(`/models/${modelId}`, {
                method: 'DELETE'
            });
            
            this.showMessage(`Successfully deleted model: ${modelName}`);
            await this.loadModels();
        } catch (error) {
            this.showError(`Failed to delete model: ${error.message}`);
        }
    }

    // 添加新模型
    async addModel(event) {
        event.preventDefault();
        
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
            this.showError('Please fill in all required fields');
            return;
        }

        // 验证ID格式
        if (!/^[a-zA-Z0-9_-]+$/.test(formData.id)) {
            this.showError('Model ID can only contain letters, numbers, underscores and hyphens');
            return;
        }

        try {
            await this.apiCall('/models', {
                method: 'POST',
                body: JSON.stringify(formData)
            });
            
            this.showMessage(`Successfully added model: ${formData.name}`);
            this.hideAddForm();
            this.clearAddForm();
            await this.loadModels();
        } catch (error) {
            this.showError(`Failed to add model: ${error.message}`);
        }
    }

    // 清空配置
    async clearConfiguration() {
        const t = this.translations[this.currentLanguage];
        
        if (!confirm(t.clearConfirm)) {
            return;
        }

        try {
            await this.apiCall('/clear', {
                method: 'POST'
            });
            
            this.showMessage('Configuration cleared');
            await this.loadCurrentStatus();
        } catch (error) {
            this.showError(`Failed to clear configuration: ${error.message}`);
        }
    }

    // 刷新状态
    async refreshStatus() {
        await this.loadCurrentStatus();
        await this.loadModels();
        this.showMessage('Status refreshed');
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