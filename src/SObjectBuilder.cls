/**
 * @author Thomas Wilkins
 * @date 4/11/2018
 * @description SObject Builder class for generating test data
 */ 
@isTest
public class SObjectBuilder {
	/**
	 * @description the type of sObject to be build
	 */
	private String sObjectType;
	/**
	 * @description the optional template to be used
	 */
	private Template t;
	/**
	 * @description the mapping of field names to values
	 */
	private Map<String, Object> fieldMapping;
	/**
	 * @description the number of records to be created
	 */
	private Integer numberOfsObjects;
	/**
	 * @description describe for fields to verify that valid fields are being added for the set sobject type
	 */
	private Map<String, Schema.SObjectField> schemaMap;

	public SObjectBuilder(String sObjectType) {
		this.init(sObjectType);
	}

	public SObjectBuilder(String sObjectType, Template t) {
		this.initWithTemplate(sObjectType, t);
	}

	/**
	 * @description sets a new template -- clears out any mapped fields or built objects
	 * @param  {Template} t the new template to be set
	 * @return {SObjectBuilder} reference to the calling SObjectBUilder
	 */
	public SObjectBuilder setTemplate(Template t) {
		this.initWithTemplate(this.sObjectType, t);
		return this;
	}

	/**
	 * @description validates the object according to the template (if applicable)
	 * @return {SObjectBuilder} reference to the calling SObjectBuilder
	 * @throws {SObjectBuilderException} if a required field does not exist in the fieldMapping
	 */
	public SObjectBuilder validate() {
		// validate required fields are set
		if (this.t != null) {
			for (String field : this.t.getRequiredFields()) {
				if (!this.fieldMapping.containsKey(field)) throw new SObjectBuilderException('Builder does not set all required fields');
			}
		}
		return this;
	}
	
	/**
	 * @description sets a field to the value
	 * @param {String} field the name of the field to be set
	 * @param {Object} value the value to be set
	 * @return {SObjectBuilder} reference to the calling SObjectBuilder
	 * @throws {SObjectBuilderException} if a required field does not exist in the fieldMapping
	 */
	public  SObjectBuilder set(String field, Object value) {
		if (schemaMap.get(field) == null) throw new SObjectBuilderException('Invalid field ' + field + ' for sObject type ' + this.sObjectType);
		this.fieldMapping.put(field, value);
		return this;
	}

	/**
	 * @description sets the number of SObjects to be made when build is called
	 * @param {Integer} numberOfsObjects the number of objects to be created
	 * @return {SObjectBuilder} reference to the calling SObjectBuilder
	 * @throws {SObjectBuilderException} if a required field does not exist in the fieldMapping
	 */
	public SObjectBuilder count(Integer numberOfsObjects) {
		if (numberOfsObjects < 1) throw new SObjectBuilderException('Number of SObjects to be created must be greater than 0');
		this.numberOfsObjects = numberOfsObjects;
		return this;
	}

	/**
	 * @description resets the builder, but not the type of SObject
	 * @return {SObjectBuilder} reference to the calling SObjectBuilder
	 */
	public SObjectBuilder reset() {
		this.fieldMapping = new Map<String, Object>();
		this.t = null;
		this.setDefaults();
		return this;
	}

	/**
	 * @description builds and returns the build sObject(s)
	 * @param {Boolean} toInsert whether or not to insert the record(s) before returning
	 * @return {Object} SObject if count is 1, List<SObject> if count > 1
	 */
	public Object build(Boolean toInsert) {
		if (this.numberOfsObjects == 1) {
			return this.buildInstance(toInsert);
		} else {
			return this.buildList(toInsert);
		}
	}

	/**
	 * @description returns a single instance of the object to build
	 * @param {Boolean} toInsert whether or not to insert the record(s) before returning
	 * @return {SObject} single instance of the sObject to build
	 */
	private SObject buildInstance(Boolean toInsert) {
		SObject obj = (SObject)Type.forName(this.sObjectType).newInstance();
		for (String field : this.fieldMapping.keySet()) {
			obj.put(field, this.fieldMapping.get(field));
		}
		if (toInsert) insert obj;
		return obj;
	}

	/**
	 * @description returns a list of the objects to build
	 * @param {Boolean} toInsert whether or not to insert the record(s) before returning
	 * @return {List<SObject>} list of the sObjects to build
	 */
	private List<SObject> buildList(Boolean toInsert) {
		List<SObject> obj = (List<SObject>)Type.forName('List<' + this.sObjectType + '>').newInstance();
		for (Integer i = 0; i < this.numberOfsObjects; i++) {
			obj.add(this.buildInstance(false));
		}
		if (toInsert) insert obj;
		return obj;
	}

	/**
	 * Inits the object builder from the template
	 * @param {String} sObjectType the type sObject to be created
	 * @param {Template} t template to initialize the object from
	 * @throws {SObjectBuilderException} if template is null
	 */
	private void initWithTemplate(String sObjectType, Template t) {
		this.init(sObjectType);
		this.t = t;
		if (this.t == null) throw new SObjectBuilderException('Template cannot be null');
		Map<String, Object> defaults = this.t.getDefaultFields();
		for (String key : defaults.keySet()) {
			this.fieldMapping.put(key, defaults.get(key));
		}
	}

	/**
	 * Inits the general object builder fields
	 * @param {String} sObjectType the type sObject to be created
	 * @throws {SObjectBuilderException} if a required field does not exist in the fieldMapping
	 */
	private void init(String sObjectType) {
		this.sObjectType = sObjectType;
		this.numberOfsObjects = 1;
		this.fieldMapping = new Map<String, Object>();
		try {
			this.schemaMap = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap();
			this.setDefaults();
		} catch (NullPointerException e) {
			throw new SObjectBuilderException('Invalid sObject type');
		}
	}
	
	/**
	 * @description sets the default values for the builder
	 */
	private void setDefaults() {
		for (String field : this.schemaMap.keySet()) {
			Schema.DescribeFieldResult fieldDescribe = this.schemaMap.get(field).getDescribe();
			if (fieldDescribe.isCreateable()) {
				Object obj = this.getDefault(fieldDescribe);
				if (obj != null) this.fieldMapping.put(field, obj);
			}
		}
	}

	/**
	 * @description gets a default value for an individual field if applicable
	 * @param {Schema.DescribeFieldResult} field the field describe to get the default for
	 * @return {Object} the default value
	 */
	private Object getDefault(Schema.DescribeFieldResult field) {
		Schema.DisplayType displayType = field.getType();
		if (this.shouldIgnoreField(displayType, field)) return null;
		else if (displayType == Schema.DisplayType.Boolean) return false;
		else if (displayType == Schema.DisplayType.Combobox) return 1;
		else if (displayType == Schema.DisplayType.Currency) return 10;
		else if (displayType == Schema.DisplayType.Date) return Date.today();
		else if (displayType == Schema.DisplayType.Datetime) return Datetime.now();
		else if (displayType == Schema.DisplayType.Double) return 10.0;
		else if (displayType == Schema.DisplayType.Email) return 'test@abc.com';
		else if (displayType == Schema.DisplayType.EncryptedString) return 'encstr';
		else if (displayType == Schema.DisplayType.Integer) return 10;
		else if (displayType == Schema.DisplayType.Percent) return 10;
		else if (displayType == Schema.DisplayType.Phone) return '555-555-5555';
		else if (displayType == Schema.DisplayType.Picklist) return this.getDefaultPicklistValue(field);
		else if (displayType == Schema.DisplayType.MultiPicklist) return this.getDefaultPicklistValue(field);
		else if (displayType == Schema.DisplayType.String) return 'Test';
		else if (displayType == Schema.DisplayType.TextArea) return 'Test';
		else if (displayType == Schema.DisplayType.Time) return Time.newInstance(0, 0, 0, 0);
		else if (displayType == Schema.DisplayType.Url) return 'https://test.com';
		else return null;
	}

	/**
	 * @description determines whether or not a field should be ignored for defaults
	 * @param {Schema.DisplayType} displayType the type of the field
	 * @param {Schema.DescribeFieldResult} field provided in case other attributes than type can be used
	 * @return {Boolean} whether or not to ignore the field
	 */
	private Boolean shouldIgnoreField(Schema.DisplayType displayType, Schema.DescribeFieldResult field) {
		return (
			displayType == Schema.DisplayType.Reference ||
			displayType == Schema.DisplayType.Id ||
			displayType == Schema.DisplayType.DataCategoryGroupReference ||
			displayType == Schema.DisplayType.address ||
			displayType == Schema.DisplayType.base64 ||
			displayType == Schema.DisplayType.String && field.getName() == 'UserName' ||
			displayType == Schema.DisplayType.String && field.getName() == 'CommunityNickname' 
		);
	}

	/** 
	 * @description gets the default picklist value for a picklist or multipicklist based on the first
	 available picklist
	 * @param {Schema.DescribeFieldResult} the field to get the picklist for
	 * @return {String} the picklist value
	 */
	private String getDefaultPicklistValue(Schema.DescribeFieldResult field) {
		List<Schema.PicklistEntry> picklistValues = field.getPicklistValues();
		return picklistValues.size() > 0 ? picklistValues[0].getValue() : null;
	}
	public class SObjectBuilderException extends Exception {}
}