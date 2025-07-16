package com.misys.tiplus2.ticc.groovy.router

import groovy.util.logging.Slf4j
import com.misys.tools.integration.impl.api.component.resource.cache.GSimpleCacheResourceImpl

@Slf4j
public class CacheHandler {
	
	final static def LOCK = new Object()
	
	/**
	 * Inserts the supplied objectToPut in a SimpleCacheResource which should be configured for the script processor
	 * calling this method
	 *
	 * @param simpleCache - SimpleCacheResource passed by the caller
	 * @param objectToPut - the object to put in cache
	 * @param objectKey - the key used to retrieve the object from cache
	 */
	def static InsertIntoCache(GSimpleCacheResourceImpl simpleCache, objectToPut, objectKey)
	{
		def cache = simpleCache
		if(cache.containsKey(objectKey)) {
			log.info "ObjectKey : ${objectKey} was already existing and was updated"
		}
		synchronized(LOCK){
			cache.put(objectKey, objectToPut)
		}
	}
	
	/**
	 * Gets the object identified by objectKey from the SimpleCacheResource sent by the caller
	 *
	 * @param simpleCache - SimpleCacheResource passed by the caller
	 * @param objectKey - the key used to retrieve the object from cache
	 */
	def static GetFromCache(GSimpleCacheResourceImpl simpleCache, objectKey)
	{
		def cache = simpleCache
		synchronized(LOCK){
			return cache.get(objectKey)
		}
	}
	
	/**
	 * Deletes the object identified by objectKey from the SimpleCacheResource sent by the caller
	 *
	 * @param simpleCache - SimpleCacheResource passed by the caller
	 * @param objectKey - the key used to retrieve the object from cache
	 */
	def static DeleteFromCache(GSimpleCacheResourceImpl simpleCache, String objectKey)
	{
		def cache = simpleCache
		synchronized(LOCK){
			cache.remove(objectKey)
		}
	}
	
}


	
	