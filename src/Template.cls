/**
 * @author Thomas Wilkins
 * @date 4/11/2018
 * @description template class for setting default values when used with an object builder
 */ 
 @isTest
public abstract class Template {

	/**
	 * @description fields that are required for this object to be valid
	 */ 
	protected Set<String> requiredFields {
		get {
			if (requiredFields == null) {
				requiredFields = new Set<String>();
			}
			return requiredFields;
		} set;
	}

	/**
	 * @description these are the actual template fields which will be set
	 */ 
	protected Map<String, Object> defaultFields {
		get {
			if (defaultFields == null) {
				defaultFields = new Map<String, Object>();
			}
			return defaultFields;
		} set;
	}
	
	/**
	 * @description Initializes based on overriden method
	 */
	public Template() { 
		init();
	}

	/**
	 * @description getter for required fields
	 * @return {Set<String>} the set of required field names
	 */ 
	public Set<String> getRequiredFields() {
		return requiredFields;
	}

	/** 
	 * @description getter for default fields
	 * @return {Map<String, Object>} the default field name/value pairs
	 */
	public Map<String, Object> getDefaultFields() {
		return defaultFields;
	}

 	/**
	 * @description method to be overriden -- should set defaultFields and requiredFields as necessary
	 */ 
	protected abstract void init();
}