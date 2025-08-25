// Claude Code API Web Interface
class ApiManager {
    constructor() {
        this.baseUrl = 'http://localhost:8080/api';
        this.init();
    }

    async init() {
        await this.loadCurrentStatus();
        await this.loadModels();
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
        
        if (status.configured) {
            container.innerHTML = `
                <div class="status-item">
                    <span class="status-label">Base URL:</span>
                    <span class="status-value">${status.baseUrl || 'Not set'}</span>
                </div>
                <div class="status-item">
                    <span class="status-label">Main Model:</span>
                    <span class="status-value">${status.model || 'Not set'}</span>
                </div>
                <div class="status-item">
                    <span class="status-label">Fast Model:</span>
                    <span class="status-value">${status.fastModel || 'Not set'}</span>
                </div>
                <div class="status-item">
                    <span class="status-label">Current Provider:</span>
                    <span class="status-value" style="font-weight: bold; color: #27ae60;">${status.provider || 'Unknown'}</span>
                </div>
            `;
        } else {
            container.innerHTML = `
                <div style="text-align: center; color: #7f8c8d;">
                    <p>🚫 No API provider currently configured</p>
                    <p>Please select a model to configure</p>
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
        
        if (!models || models.length === 0) {
            container.innerHTML = '<div class="loading">No model configurations found</div>';
            return;
        }

        container.innerHTML = models.map(model => `
            <div class="model-card" data-model-id="${model.id}">
                <h3>${model.name}</h3>
                <div class="model-info">
                    <span><strong>Description:</strong> ${model.description || 'No description'}</span>
                    <span><strong>API:</strong> ${model.base_url}</span>
                    <span><strong>Environment Variable:</strong> ${model.api_key_env}</span>
                    <span><strong>Models:</strong> ${model.model} / ${model.fast_model}</span>
                </div>
                <div class="button-group">
                    <button class="btn btn-primary" onclick="apiManager.switchToModel('${model.id}')">
                        Switch to this model
                    </button>
                    <button class="btn btn-danger" onclick="apiManager.deleteModel('${model.id}', '${model.name}')">
                        Delete
                    </button>
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

    // 删除模型
    async deleteModel(modelId, modelName) {
        if (!confirm(`Are you sure you want to delete model "${modelName}" (${modelId})? This operation cannot be undone.`)) {
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
        if (!confirm('Are you sure you want to clear the current API configuration?')) {
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